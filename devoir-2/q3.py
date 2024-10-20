import os
import re
from os.path import exists
from typing import List

import pandas as pd
from tqdm import tqdm

from q2 import cut_audio, download_audio


def filter_df(csv_path: str, label: str) -> pd.DataFrame:
    """
    Écrivez une fonction qui prend le path vers le csv traité (dans la partie notebook de q1) et renvoie un df avec seulement les rangées qui contiennent l'étiquette `label`.

    Par exemple:
    get_ids("audio_segments_clean.csv", "Speech") ne doit renvoyer que les lignes où l'un des libellés est "Speech"
    """
    df = pd.read_csv(csv_path)

    labels = df["label_names"]
    sublists = labels.str.split("|")
    mask = [label in sublist for sublist in sublists]

    return pd.DataFrame(df[mask])


def data_pipeline(csv_path: str, label: str) -> None:
    """
    En utilisant vos fonctions précédemment créées, écrivez une fonction qui prend un csv traité et pour chaque vidéo avec l'étiquette donnée:
    1. Le télécharge à <label>_raw/<ID>.mp3
    2. Le coupe au segment approprié
    3. L'enregistre dans <label>_cut/<ID>.mp3

    Il est recommandé d'itérer sur les rangées de filter_df().
    Utilisez tqdm pour suivre la progression du processus de téléchargement (https://tqdm.github.io/)

    Malheureusement, il est possible que certaines vidéos ne peuvent pas être téléchargées. Dans de tels cas, votre pipeline doit gérer l'échec en passant à la vidéo suivante avec l'étiquette.
    """

    # Create audio directory
    if not exists("./audio"):
        os.mkdir("./audio")

    # Create label directories
    path_raw = f"./audio/{label}_raw"
    path_cut = f"./audio/{label}_cut"

    if not exists(path_raw):
        os.mkdir(path_raw)
    if not exists(path_cut):
        os.mkdir(path_cut)

    filtered_df = filter_df(csv_path, label)
    for index, series in tqdm(filtered_df.iterrows()):
        start = float(series[" start_seconds"])
        end = float(series[" end_seconds"])
        ID = str(series["# YTID"])
        path_raw_full = f"{path_raw}/{ID}.mp3"
        path_cut_full = f"{path_cut}/{ID}.mp3"

        try:
            download_audio(ID, path_raw_full)
            cut_audio(path_raw_full, path_cut_full, start, end)
        except Exception as e:
            print(f"Error while downloading {ID}: {e}")
            continue


def rename_files(path_cut: str, csv_path: str) -> None:
    """
    Supposons que nous voulons maintenant renommer les fichiers que nous avons téléchargés dans `path_cut` pour inclure les heures de début et de fin ainsi que la longueur du segment. Alors que
    cela aurait pu être fait dans la fonction data_pipeline(), supposons que nous avons oublié et que nous ne voulons pas tout télécharger à nouveau.

    Écrivez une fonction qui, en utilisant regex (c'est-à-dire la bibliothèque `re`), renomme les fichiers existants de "<ID>.mp3" -> "<ID>_<start_seconds_int>_<end_seconds_int>_<length_int>.mp3"
    dans path_cut. csv_path est le chemin vers le csv traité à partir de q1. `path_cut` est un chemin vers le dossier avec l'audio coupé.

    Par exemple
    "--BfvyPmVMo.mp3" -> "--BfvyPmVMo_20_30_10.mp3"

    ## ATTENTION : supposez que l'YTID peut contenir des caractères spéciaux tels que '.' ou même '.mp3' ##
    """
    df = pd.read_csv(csv_path)

    if not exists(path_cut):
        print(f"Directory {path_cut} does not exist")
        return

    files = os.listdir(path_cut)

    if len(files) == 0:
        print(f"No files in {path_cut}")
        return

    for file in tqdm(files):
        # Extract the YTID using regex
        ID = re.findall(r"(.*).mp3", file)[0]
        # Extract the row from the csv
        row = df[df["# YTID"] == ID]

        if row.empty:
            continue

        row = row.iloc[0]

        # Extract the start, end and duration
        start = int(row[" start_seconds"])
        end = int(row[" end_seconds"])
        duration = end - start
        # Rename the file (use replace to overwrite the file if it exists)
        os.replace(f"{path_cut}/{file}", f"{path_cut}/{ID}_{start}_{end}_{duration}.mp3")


if __name__ == "__main__":
    print(filter_df("audio_segments_clean.csv", "Laughter"))
    # data_pipeline("audio_segments_clean.csv", "Laughter")
    rename_files("./audio/Laughter_cut", "audio_segments_clean.csv")
