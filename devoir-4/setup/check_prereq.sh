#!/bin/bash

# Get user input for student ID
read -p "Votre numéro de matricule / Enter your student ID: " student_id

# Strip leading and trailing whitespace from student ID
student_id=$(echo "$student_id" | sed 's/^[ \t]*//;s/[ \t]*$//')

# Check if gcloud is installed
echo "Vérification que gcloud est installé / Checking if gcloud is installed ..."
if ! command -v gcloud &> /dev/null; then
    echo ""
    echo "ATTN:gcloud n'est pas installé. Veuillez installer gcloud / gcloud is not installed. Please install gcloud before running this script."
    exit 1
fi

# Check that the project is set to hw5-${student_id}
PROJECT_ID="hw5-${student_id}"
PROJECT_REGION="us-central1"

echo "Vérification que l'ID du projet est / Checking if the project is set to ${PROJECT_ID}..."
project_name=$(gcloud config get-value project)
if [ "$project_name" != "${PROJECT_ID}" ]; then
    echo ""
    echo "ATTN: L'ID du projet n'est pas correct. / Project is not set to ${PROJECT_ID}. Please set the project to ${PROJECT_ID} before running this script."
    exit 1
fi

# Check that the following services are enabled:
# - Cloud Run
# - Artifact Registry
# - Cloud Build
echo "Vérifier que Cloud Run est activé / Checking if Cloud Run is enabled..."
gcloud services list --enabled --format="value(config.name)" | grep -q "run.googleapis.com"
if [ $? -ne 0 ]; then
    echo ""
    echo "ATTN: Cloud Run n'est pas activé. / Cloud Run is not enabled. Please enable Cloud Run before running this script."
    exit 1
fi

echo "Vérifier que Cloud Build est activé / Checking if Cloud Build is enabled..."
gcloud services list --enabled --format="value(config.name)" | grep -q "cloudbuild.googleapis.com"
if [ $? -ne 0 ]; then
    echo ""
    echo "ATTN: Cloud Build n'est pas activé. / Cloud Build is not enabled. Please enable Cloud Build before running this script."
    exit 1
fi

echo "Vérifier que Artifact Registry est activé / Checking if Artifact Registry is enabled..."
gcloud services list --enabled --format="value(config.name)" | grep -q "artifactregistry.googleapis.com"
if [ $? -ne 0 ]; then
    echo ""
    echo "ATTN: Artifact Registry n'est pas activé. / Artifact Registry is not enabled. Please enable Artifact Registry before running this script."
    exit 1
fi

# Check that a Docker registry exists with the following setup:
# - Location: us-central1
# - Repository: hw5-images
REPO_NAME="hw5-images"
REPO_PATH="${PROJECT_REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}"
echo "Vérification que le "Docker registry" existe. / Checking if a Docker registry exists with the following setup:"
echo " - Location: ${PROJECT_REGION}"
echo " - Repository: ${REPO_NAME}"

if gcloud artifacts repositories describe "${REPO_NAME}" \
    --project="${PROJECT_ID}" \
    --location="${PROJECT_REGION}" &> /dev/null
then
    echo "Repository ${REPO_PATH} exists"
else
    echo ""
    echo "ATTN: Repository ${REPO_PATH} does not exist"
    exit 1
fi

# Check python is installed and has yaml package
echo "Vérifier que Python est installé. / Checking if python is installed..."
if ! command -v python3 &> /dev/null; then
    echo ""
    echo "ATTN: Python n'est pas installé. Veuillez installer Python. / Python may not be installed. Please double check your Python installation before running this script."
fi

echo "Vérification que le package Python "yaml" est installé. / Checking if python has yaml package..."
if ! python3 -c "import yaml" &> /dev/null; then
    echo ""
    echo "ATTN: Le package Python "yaml" n'est pas installé. Veuillez installer le package Python yaml (pyyaml). / Python does not have the yaml package. Please install the yaml package (pyyaml) before running this script."
    exit 1
fi

# Everything probably worked, so we can exit with a success message and status.
echo "Les vérifications sont complètes. Vous pouvez commencer vos devoirs. / All prerequisites are met. You can proceed with the assignment."
exit 0
