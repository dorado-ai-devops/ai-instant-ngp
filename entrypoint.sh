#!/usr/bin/env bash
set -euo pipefail
export PYTHONPATH=/app/instant-ngp/build:${PYTHONPATH:-}

DATA_PATH=${DATA_PATH:-/data/lego-ds}
N_STEPS=${N_STEPS:-15000}
FAST=${FAST:-0}
FACTOR=${FACTOR:-2}
LR_W=${LR_W:-960}; LR_H=${LR_H:-540}

if [[ "$FAST" == "1" || "$FAST" == "true" ]]; then
  TF="$DATA_PATH/transforms_lr.json"
  SNAP="$DATA_PATH/model_lr.ingp"
else
  TF="$DATA_PATH/transforms.json"
  SNAP="$DATA_PATH/model.ingp"
fi
RUN ln -s /usr/bin/python3 /usr/local/bin/python
# Standalone NGP Mode
echo "==> Ejecutando pipeline NGP..."
python3 /app/train_ngp.py \
    --data "$DATA_PATH" \
    --steps "$N_STEPS" --snapshot "$SNAP"

# Fast NeRF Mode
if [[ "$FAST" == "1" || "$FAST" == "true" ]]; then
  echo "==> Ejecutando pipeline Fast NeRF..."
  python3 /app/render_pairs.py \
        --snapshot "$SNAP" --out "$DATA_PATH" \
        --lr "$LR_W" "$LR_H" --factor "$FACTOR"
  python3 /app/train_sr.py \
        --lr_dir "$DATA_PATH/renders_lr" \
        --hr_dir "$DATA_PATH/renders_hr" \
        --out "$DATA_PATH/sr_model.pth" --scale "$FACTOR"
fi
