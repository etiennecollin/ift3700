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

REGION="us-central1"
PROJECT_ID="hw5-20237904"

# This makes sure that we are uploading our code from the proper path.
# Don't change this line.
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

REPO_NAME="hw5-images"
REGISTRY="${REGION}-docker.pkg.dev"
APP_IMAGE="${VTYPE}_v${VERSION}" # (frontend_v1, backend_v1, frontend_v2 or backend_v2)
TARGET_DOCKERFILE="Dockerfile.${APP_IMAGE}"
SERVING_PORT="8000"

# It's not expected to know bash scripting to the level below.
# The following is known as substitutions in cloud build.

# The full path to an image is a combination of the
# registry, project ID, repository name, and the image name.
# REGION-docker.pkg.dev/PROJECT_ID/REPO_NAME/IMAGE_NAME:TAG
REPO_URI="${REGISTRY}/${PROJECT_ID}/${REPO_NAME}"
BASE_IMAGE_URI="${REPO_URI}/base_image"
APP_URI="${REPO_URI}/${APP_IMAGE}"

REPO_URI="${REGISTRY}/${PROJECT_ID}/${REPO_NAME}"
gcloud builds submit \
    --region=${REGION} \
    --config="${SCRIPT_DIR}/cloudbuild.yaml" \
    --substitutions=_BASE_IMAGE_URI="${BASE_IMAGE_URI}",_APP_URI="${APP_URI}",_SERVING_PORT=${SERVING_PORT},_TARGET_DOCKERFILE="${TARGET_DOCKERFILE}" \
    ${SCRIPT_DIR}/../
