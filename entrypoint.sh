#!/usr/bin/env bash
set -euo pipefail
export PYTHONPATH=/app/instant-ngp/build:${PYTHONPATH:-}

DATA_PATH=${DATA_PATH:-/data/lego-ds}
N_STEPS=${N_STEPS:-15000}
FAST=${FAST:-0}  
FACTOR=${FACTOR:-2}
LR_W=${LR_W:-$((4000 / FACTOR))}
LR_H=${LR_H:-$((3000 / FACTOR))}


if [[ "$FAST" == "1" || "$FAST" == "true" ]]; then
    cp "$DATA_PATH/transforms_lr.json" "$DATA_PATH/transforms.json"   # activar LR
    SNAP="$DATA_PATH/model_lr.ingp"
else
    SNAP="$DATA_PATH/model.ingp"
fi


echo "==> Entrenando NeRF ..."
python3 /app/train_ngp.py \
        --data "$DATA_PATH" \
        --steps "$N_STEPS" \
        --snapshot "$SNAP"


if [[ "$FAST" == "1" || "$FAST" == "true" ]]; then
    echo "==> Generando pares LR/HR ..."
    python3 /app/render_pairs.py \
            --snapshot "$SNAP" --out "$DATA_PATH" \
            --lr "$LR_W" "$LR_H" --factor "$FACTOR"

    echo "==> Entrenando super‑resolución..."
    /venv_sr/bin/python3 /app/train_sr.py \
        --lr_dir "$DATA_PATH/renders_lr" \
        --hr_dir "$DATA_PATH/renders_hr" \
        --out    "$DATA_PATH/sr_model.pth" \
        --scale  "$FACTOR"
fi
