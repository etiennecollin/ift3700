REPO_NAME="hw5-images"
LOCATION="us-central1"
PROJECT_ID="hw5-20237904"

gcloud config set project "$PROJECT_ID"

gcloud config list

gcloud services enable artifactregistry.googleapis.com run.googleapis.com cloudbuild.googleapis.com

gcloud artifacts repositories create "$REPO_NAME" \
    --repository-format=docker \
    --location="$LOCATION" \
    --project="$PROJECT_ID"

gcloud artifacts repositories list --project="$PROJECT_ID"

./setup/check_prereq.sh
