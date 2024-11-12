#!/usr/bin/env bash

# The first argument should be the version type
VTYPE="$1"
if [ -z "$VTYPE" ]; then
    echo "Please provide whether the build is for the 'backend' or 'frontend'"
    exit 1
fi

if [[ "$VTYPE" != "backend" && "$VTYPE" != "frontend" ]]; then
    echo "Invalid version type. Only 'backend' or 'frontend' are allowed."
    exit 1
fi

# The second argument should be the version number
VERSION="$2"
if [ -z "$VERSION" ]; then
    echo "Please provide a version number for the backend"
    exit 1
fi

# Check that the version is 1 or 2
if [[ "$VERSION" != "1" && "$VERSION" != "2" ]]; then
    echo "Invalid version. Only version 1 or 2 are allowed."
    exit 1
fi

# Backend URL
SERVING_URL="$3"
if [[ "$SERVING_URL" == "" && "$VTYPE" == "frontend" ]]; then
    echo "Please provide the backend URL"
    exit 1
fi

REGION="us-central1"
PROJECT_ID="hw5-20237904"
REPO_NAME="hw5-images"

# This is the service you will be deploying.
SERVICE_NAME="${VTYPE}v${VERSION}"
IMAGE_NAME="${VTYPE}_v${VERSION}"

# Put your image URI here corresponding to the service above.
# An IMAGE URI has the following format:
# REGION-docker.pkg.dev/PROJECT_ID/REPO_NAME/IMAGE_NAME:TAG
IMAGE_URI="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:b41abcea-3a5f-49be-82b3-c808c199f8d1"

# This should be the same port as the one used when building the image.
SERVING_PORT="8000"

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
