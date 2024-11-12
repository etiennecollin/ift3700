#!/usr/bin/env bash

REGION="us-central1"
PROJECT_ID="hw5-20237904"
REPO_NAME="hw5-images"

# This is the service you will be deploying.
SERVICE_NAME="frontendv1"
IMAGE_NAME="frontend_v1"
IMAGE_TAG="acd3fb09-a52b-461d-a329-fe84772ed077"

# Put your image URI here corresponding to the service above.
# An IMAGE URI has the following format:
# REGION-docker.pkg.dev/PROJECT_ID/REPO_NAME/IMAGE_NAME:TAG
IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"

# This should be the same port as the one used when building the image.
SERVING_PORT="8000"
SERVING_URL="https://backendv1-1023316180722.us-central1.run.app"

# NOTE: Default values are set for memory and cpu
# but you may need to change these.

gcloud run deploy ${SERVICE_NAME} \
    --region=${REGION} \
    --image=${IMAGE_URI} \
    --min-instances=1 \
    --max-instances=1 \
    --memory="2Gi" \
    --cpu=2 \
    --port=${SERVING_PORT} \
    --allow-unauthenticated \
    --set-env-vars="SERVING_URL=${SERVING_URL}"

# NOTE: In a production environment, we may not want
# to allow anyone to access our service(s). For the
# purposes of this assignment, it is fine to have
# it public facing.
