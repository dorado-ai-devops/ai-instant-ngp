#!/bin/bash
set -e
DATA_PATH=${DATA_PATH:-/data/lego-ds}  
/app/instant-ngp/build/instant-ngp \
  --mode nerf \
  --scene "$DATA_PATH/images" \
  --no-gui
