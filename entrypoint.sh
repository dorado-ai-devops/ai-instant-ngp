#!/usr/bin/env bash
set -euo pipefail
export PYTHONPATH=/app/instant-ngp/build:${PYTHONPATH:-}

DATA_PATH=${DATA_PATH:-/data/lego-ds}
N_STEPS=${N_STEPS:-15000}
FAST=${FAST:-0}                    


if [[ "$FAST" == "1" || "$FAST" == "true" ]]; then
    echo "==> FastSR‑NeRF (LR)"
    SCENE="$DATA_PATH"                            
    TF_FILE="$DATA_PATH/transforms_lr.json"      
    SNAPSHOT="$DATA_PATH/model_lr.ingp"
else
    echo "==> NeRF estándar (HR)"
    SCENE="$DATA_PATH"
    TF_FILE="$DATA_PATH/transforms.json"
    SNAPSHOT="$DATA_PATH/model.ingp"
fi


echo "==> Ejecutando Instant‑NGP"
if ! python3 /app/instant-ngp/scripts/run.py \
        --scene "$SCENE" \
        --transforms "$TF_FILE" \
        --n_steps "$N_STEPS" \
        --save_snapshot "$SNAPSHOT"; then

    echo "Entrenamiento fallido; dataset en ${DATA_PATH} listo para depurar (2 min)…"
    sleep 120
    exit 1
fi

echo "Entrenamiento completado."
ls -lh "$SNAPSHOT"
