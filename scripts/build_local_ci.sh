#!/bin/bash

# NB: This file is intended for local debugging of CI Docker stuff. The scripts that actually run in CloudBuild are
#     located in the ./.cloudbuild directory of this repo

docker build \
  -t lamdera-ci:local \
  --file ./.cloudbuild/Dockerfile-Ci \
  .
