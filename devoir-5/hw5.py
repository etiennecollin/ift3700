import numpy as np
import pandas as pd
import seaborn as sns
import shap
from eli5.sklearn import PermutationImportance
from matplotlib import pyplot as plt
from sklearn.ensemble import RandomForestClassifier
from sklearn.inspection import PartialDependenceDisplay
from sklearn.metrics import accuracy_score, classification_report
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder


def load_data(file_path: str) -> pd.DataFrame:
    """
    Charge l'ensemble de données depuis un fichier CSV.

    Paramètres:
    - file_path (str): Chemin vers le fichier CSV contenant l'ensemble de données.

    Renvoie:
    - pd.DataFrame: Ensemble de données chargé sous forme de DataFrame.
    """
    data = pd.read_csv(file_path)
    return data


def encode_target_column(data) -> pd.DataFrame:
    """
    Encode la colonne "is_readmitted" (cible) en valeurs numériques (True -> 1, False -> 0).

    Paramètres:
    - data (pd.DataFrame): DataFrame d'entrée contenant la colonne "is_readmitted".

    Renvoie:
    - pd.DataFrame: DataFrame avec la colonne "is_readmitted" encodée.
    """
    data = data.copy()

    # Initialisation du LabelEncoder
    label_encoder = LabelEncoder()

    # Encodage de la colonne "is_readmitted" en valeurs numériques
    data["is_readmitted"] = label_encoder.fit_transform(data["is_readmitted"])

    return data


def split_data(data: pd.DataFrame, target: str, test_size: float = 0.2, random_state: int = 42) -> tuple:
    """
    Divise les données en ensembles d'entraînement et de test.

    Paramètres:
    - data (pd.DataFrame): Ensemble de données d'entrée.
    - test_size (float): Proportion de l'ensemble de données à inclure dans la division de test.

    Renvoie:
    - tuple: Un tuple contenant les DataFrames X_train, X_test, y_train et y_test.
    """
    X = data.drop(columns=[target])
    y = data[target]
    X_train, X_val, y_train, y_val = train_test_split(X, y, test_size=test_size, random_state=random_state)
    return X_train, X_val, y_train, y_val


def train_random_forest(
    X_train: pd.DataFrame,
    y_train: pd.Series,
    n_estimators: int = 100,
    max_depth: int = None,
    random_state: int = 42,
) -> RandomForestClassifier:
    """
    Entraîne un classificateur Random Forest.

    Paramètres:
    - X_train (pd.DataFrame): Caractéristiques de l'ensemble d'entraînement.
    - y_train (pd.Series): Étiquettes cibles de l'ensemble d'entraînement.
    - n_estimators (int): Nombre d'arbres dans la forêt.
    - max_depth (int): Profondeur maximale des arbres de la forêt (par défaut=None).

    Renvoie:
    - RandomForestClassifier: Modèle Random Forest entraîné.
    """
    # Initialisation du classificateur Random Forest
    model = RandomForestClassifier(n_estimators=n_estimators, max_depth=max_depth, random_state=random_state)

    # Entraînement du modèle
    model.fit(X_train, y_train)

    # Retour du modèle entraîné
    return model


def evaluate_model(model: RandomForestClassifier, X_test: pd.DataFrame, y_test: pd.Series) -> tuple:
    """
    Évalue le modèle Random Forest.

    Paramètres:
    - model (RandomForestClassifier): Modèle Random Forest entraîné.
    - X_test (pd.DataFrame): Caractéristiques de l'ensemble de test.
    - y_test (pd.Series): Étiquettes cibles de l'ensemble de test.

    Renvoie:
    - tuple: Un tuple contenant la précision (float) et le rapport de classification (str).
    """
    # Prédictions du modèle sur l'ensemble de test
    y_pred = model.predict(X_test)

    # Calculer la précision
    accuracy = accuracy_score(y_test, y_pred)

    # Obtenir le rapport de classification
    report = classification_report(y_test, y_pred)

    # Retourner la précision et le rapport de classification
    return accuracy, report


def calculate_permutation_importance(
    model,
    X_val: pd.DataFrame,
    y_val: pd.Series,
    random_state: int = 1,
):
    """
    Calcule les importances par permutation pour un modèle d'apprentissage automatique.

    Paramètres:
    - model: Modèle d'apprentissage automatique entraîné.
    - X_val: Caractéristiques de l'ensemble de validation.
    - y_val: Étiquettes cibles de l'ensemble de validation.

    Renvoie:
    - eli5.PermutationImportance: Objet PermutationImportance avec les importances calculées. Nous n'utiliserons que le modèle et la valeur prédéfinie pour random_state.
    """
    # Initialisation de PermutationImportance avec le modèle et le random_state
    perm_importance = PermutationImportance(model, random_state=random_state)

    # Calcul des importances par permutation
    perm_importance.fit(X_val, y_val)

    # Retourner l'objet contenant les importances calculées
    return perm_importance


def plot_partial_dependence(model, X_val: pd.DataFrame, feature_name: str):
    """
    Affiche les tracés de dépendance partielle pour une caractéristique spécifiée.

    Paramètres:
    - model: Modèle d'apprentissage automatique entraîné.
    - X_val: Caractéristiques de l'ensemble de validation.
    - feature_name: Nom de la caractéristique pour laquelle créer les tracés de dépendance partielle.
    """
    # Vérifier si le feature_name est bien une colonne dans X_val
    if feature_name not in X_val.columns:
        raise ValueError(f"La caractéristique '{feature_name}' n'est pas présente dans X_val.")

    # Créer un objet PartialDependenceDisplay
    pdp_display = PartialDependenceDisplay.from_estimator(model, X_val, features=[feature_name])

    pdp_display.figure_.suptitle(f"Tracé de Dépendance Partielle pour {feature_name}")

    plt.grid(True)


def plot_mean_readmission_vs_time(X_train, y_train):
    """
    Tracez le taux de réadmission moyen par rapport au temps à l'hôpital.

    Paramètres:
    - X_train (pd.DataFrame): Caractéristiques de l'ensemble de formation.
    - y_train (pd.Series): Étiquettes cibles (is_readmitted) de l'ensemble de formation.
    """
    # Combiner les caractéristiques et les étiquettes cibles dans un seul DataFrame
    all_train = pd.concat([X_train, y_train], axis=1)

    # Vérifier que la colonne "time_in_hospital" existe dans X_train
    if "time_in_hospital" not in all_train.columns:
        raise ValueError("La colonne 'time_in_hospital' doit être présente dans X_train.")

    # Calculer la moyenne de 'is_readmitted' pour chaque valeur de 'time_in_hospital'
    mean_readmission = all_train.groupby("time_in_hospital")["is_readmitted"].mean()

    # Pas besoin de modifier la partie suivante
    plt.figure(figsize=(10, 6))
    sns.lineplot(
        x=mean_readmission.index,
        y=mean_readmission.values,
        marker="o",
        color="royalblue",
    )
    plt.xlabel("Temps à l'hôpital")
    plt.ylabel("Taux de Réadmission Moyen")
    plt.title("Taux de Réadmission Moyen vs Temps à l'Hôpital")
    plt.grid(True)

    plt.show()


def main_factors(model: RandomForestClassifier, sample_data: pd.Series):
    """
    Calcule et affiche les valeurs SHAP en utilisant un modèle donné et des données d'exemple.

    Paramètres:
    - model: Modèle d'apprentissage automatique entraîné.
    - sample_data: Données pour lesquelles les valeurs SHAP seront calculées et affichées.

    Renvoie:
    - shap.Explanation: Tracé de force SHAP pour les données fournies.
    """
    # Initialisation de la visualisation JavaScript SHAP
    shap.initjs()

    # Créer un objet explainer pour calculer les valeurs SHAP
    explainer = shap.TreeExplainer(model)

    # Calculer les valeurs SHAP
    shap_values = explainer.shap_values(sample_data).T

    # Afficher le tracé de force SHAP
    return shap.force_plot(explainer.expected_value[1], shap_values[1], sample_data)


def remove_outliers_iqr(
    df: pd.DataFrame,
    columns_to_process: list,
    predictor_column: str,
    threshold: float = 1.5,
) -> pd.DataFrame:
    """
    Supprime les lignes avec des valeurs aberrantes des colonnes de caractéristiques spécifiques en ignorant une colonne cible en utilisant la méthode IQR.

    Paramètres:
        df (pd.DataFrame): Le DataFrame d'entrée contenant à la fois des colonnes de caractéristiques numériques et de prédiction.
        columns_to_process (list): Une liste de noms de colonnes à traiter pour la suppression des valeurs aberrantes.
        predictor_column (str): Le nom de la colonne cible à ignorer lors de la détection des valeurs aberrantes.
        threshold (float, optionnel): Le multiplicateur de seuil pour définir les limites des valeurs aberrantes. Par défaut, c'est 1.5.

    Renvoie:
        pd.DataFrame: Un DataFrame nettoyé avec les lignes aberrantes supprimées.
    """
    # Créez une copie du DataFrame pour éviter de modifier l'original
    df_cleaned = df.copy()

    # Parcourir chaque colonne spécifiée
    for column in columns_to_process:
        if column != predictor_column and column in df.columns:
            # Calculer les quantiles Q1 et Q3
            Q1 = df_cleaned[column].quantile(0.25)
            Q3 = df_cleaned[column].quantile(0.75)

            # Calculer l'IQR
            IQR = Q3 - Q1

            # Définir les bornes inférieure et supérieure
            lower_bound = Q1 - (threshold * IQR)
            upper_bound = Q3 + (threshold * IQR)

            # Supprimer les lignes avec des valeurs aberrantes
            df_cleaned = df_cleaned[(df_cleaned[column] >= lower_bound) & (df_cleaned[column] <= upper_bound)]

    # Réinitialiser l'index du DataFrame nettoyé
    df_cleaned.reset_index(inplace=True)

    return df_cleaned


def add_absolute_coordinate_changes(df: pd.DataFrame) -> pd.DataFrame:
    """
    Ajoute les colonnes 'abs_lon_change' et 'abs_lat_change' à un DataFrame existant, représentant le changement absolu
    de longitude et de latitude entre les coordonnées 'dropoff' et 'pickup'.

    Paramètres:
        df (pd.DataFrame): Le DataFrame d'entrée contenant les colonnes 'pickup_longitude', 'pickup_latitude',
                           'dropoff_longitude' et 'dropoff_latitude'.

    Renvoie:
        pd.DataFrame: Le DataFrame avec les colonnes ajoutées.
    """
    df = df.copy()

    # Calculer les changements absolus de longitude et de latitude
    df["abs_lon_change"] = abs(df["dropoff_longitude"] - df["pickup_longitude"])
    df["abs_lat_change"] = abs(df["dropoff_latitude"] - df["pickup_latitude"])

    return df
