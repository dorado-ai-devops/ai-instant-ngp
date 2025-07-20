#!/bin/bash
set -e
DATA_PATH=${DATA_PATH:-/data/lego-ds}  # Valor por defecto si no se define la env var
/app/instant-ngp/build/instant-ngp --mode nerf --scene "$DATA_PATH" --no-gui
