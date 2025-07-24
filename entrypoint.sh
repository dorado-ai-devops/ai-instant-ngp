#!/bin/bash
set -euo pipefail
ls /app/instant-ngp/build/pyngp.*
export PYTHONPATH=/app/instant-ngp/build:${PYTHONPATH:-}
DATA_PATH=${DATA_PATH:-/data/lego-ds}  
N_STEPS=${N_STEPS:-15000}
echo "==> Ejecutando Instant-NGP"
if ! python3 /app/instant-ngp/scripts/run.py \
  --scene "$DATA_PATH" \
  --n_steps $N_STEPS \
  --save_snapshot "$DATA_PATH/model.ingp"; then

    echo "Entrenamiento fallido"
    echo "Esperando 2 minutos para debug (PVC montado en ${DATA_PATH})..."
    sleep 120

    echo "Limpiando dataset tras fallo"
    rm -rf /tmp/tmp_cloned
    rm -rf "${DATA_PATH:?}/colmap"
    rm -rf "${DATA_PATH:?}/images"
    rm -f "${DATA_PATH:?}/transforms.json"

    exit 1
fi

echo "Entrenamiento completado."
ls -lh "${DATA_PATH}/model.ingp"
echo "Modelo guardado en ${DATA_PATH}/model.ingp"


