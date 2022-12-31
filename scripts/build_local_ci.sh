#!/bin/bash

# NB: This file is intended for local debugging of CI Docker stuff. The scripts that actually run in CloudBuild are
#     located in the ./.cloudbuild directory of this repo
#     The tag below matches the one used in the ci process. You should not push to GCR manually, but the same tag is
#     used here to simplify local testing of a newly built image.
docker build \
  -t gcr.io/fir-sandbox-326008/lamdera-ci:latest \
  --file ./.cloudbuild/Dockerfile-Ci \
  .
