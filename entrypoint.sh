#!/bin/bash
set -e

DATA_PATH=${DATA_PATH:-/data/lego-ds}  

echo "==> Ejecutando Instant-NGP"
if ! /app/instant-ngp/build/instant-ngp \
  --mode nerf \
  --scene "$DATA_PATH" \
  --no-gui \
  --n_steps 30000 \
  --save_snapshot "$DATA_PATH/model.ingp"; then

    echo "Entrenamiento fallido"
    echo "Esperando 10 minutos para debug (PVC montado en ${DATA_PATH})..."
    sleep 600

    echo "🧹 Limpiando dataset tras fallo"
    rm -rf /tmp/tmp_cloned
    rm -rf "${DATA_PATH:?}/colmap"
    rm -rf "${DATA_PATH:?}/images"
    rm -f "${DATA_PATH:?}/transforms.json"

    exit 1
fi

echo "Entrenamiento completado correctamente"
