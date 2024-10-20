import csv
import os
import threading
from os.path import exists

import ffmpeg
import numpy as np
import pandas as pd
import yt_dlp
from tqdm import tqdm

COOKIES_FILE_PATH = "./cookies.txt"


def download_audio(YTID: str, path: str) -> None:
    """
    Créez une fonction qui télécharge l'audio de la vidéo Youtube avec un identifiant donné
    et l'enregistre dans le dossier donné par `path`. Téléchargez-le en mp3. S'il y a un problème lors du téléchargement du fichier, gérez l'exception. Si il y a déjà un fichier à `path`, la fonction devrait retourner sans tenter de le télécharger à nouveau.

    ** Utilisez la librairie youtube_dl : https://github.com/ytdl-org/youtube-dl/ **

    Arguments :
    - YTID : Contient l'identifiant youtube, la vidéo youtube correspondante peut être trouvée sur
    'https://www.youtube.com/watch?v='+YTID
    - path : Le chemin d'accès au fichier où l'audio sera enregistré
    """

    # Do not download if file already exists
    if exists(path):
        print(f"File already exists at {path}")
        return

    # # Make sure cookies file exists and the .env file exists
    # if not exists(COOKIES_FILE_PATH):
    #     raise FileNotFoundError("Cookies file not found")

    # if not exists(".env"):
    #     raise FileNotFoundError(".env file not found")

    # # Get po_token from .env file
    # from dotenv import load_dotenv
    # load_dotenv()
    # po_token = os.getenv("PO_TOKEN")

    url = f"https://www.youtube.com/watch?v={YTID}"
    ydl_opts = {
        # "extractor-args": f"youtube:player-client=web,default;po_token=web+{po_token}",
        "format": "bestaudio/best",
        # "cookies": COOKIES_FILE_PATH,
        "outtmpl": path,
    }
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])


def cut_audio(in_path: str, out_path: str, start: float, end: float) -> None:
    """
    Créez une fonction qui coupe l'audio de in_path pour n'inclure que le segment de start à end et l'enregistre dans out_path.

    ** Utilisez la bibliothèque ffmpeg : https://github.com/kkroening/ffmpeg-python
    Arguments :
    - in_path : Chemin du fichier audio à couper
    - out_path : Chemin du fichier pour enregistrer l'audio coupé
    - start : Indique le début de la séquence (en secondes)
    - end : Indique la fin de la séquence (en secondes)
    """
    # Do not download if file already exists
    if exists(out_path):
        print(f"File already cut at {out_path}")
        return

    duration = end - start
    ffmpeg.input(in_path, ss=start, t=duration).output(out_path).run(overwrite_output=True)
