#!/usr/bin/env bash

mkdir -p upload

cp ./deliverables.yaml ./upload/
cp ./HW5EtienneCollin_20237904.md ./upload/

cp ./deployment/deploy_backend_v1.sh ./upload/
cp ./deployment/deploy_backend_v2.sh ./upload/
cp ./deployment/deploy_frontend_v1.sh ./upload/
cp ./deployment/deploy_frontend_v2.sh ./upload/

cp ./deployment/cloudbuild.yaml ./upload/

cp ./deployment/submit_build_backend_v1.sh ./upload/submit_build.sh
