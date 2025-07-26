# 🚀 ai-instant-ngp

Entrenador de NeRF (Neural Radiance Fields) basado en [Instant-NGP](https://github.com/NVlabs/instant-ngp) de NVIDIA, optimizado para CUDA y containerizado para despliegue en Kubernetes. Incluye pipeline completo de entrenamiento NeRF y +FastNerf.

## 🔧 Requisitos

- Docker con soporte NVIDIA
- CUDA 12.9+
- GPU compatible
- Kubernetes + ArgoCD (para despliegue)
- Registro de contenedores local (default: localhost:5000)

## 📦 Estructura

```
ai-instant-ngp/
├── Dockerfile          # Contenedor con dependencias CUDA
├── Makefile           # Scripts de build y despliegue
├── Jenkinsfile        # Pipeline CI/CD
├── entrypoint.sh      # Script de inicio del contenedor
├── train_ngp.py       # Entrenamiento del modelo NeRF
├── render_pairs.py    # Generación de pares LR/HR
└── train_sr.py        # Entrenamiento de super-resolución
```

## 🤖 Pipeline de Entrenamiento

El proceso completo consta de tres fases:

### 1. Entrenamiento NeRF (train_ngp.py)
```bash
python3 train_ngp.py \
  --data /ruta/escena \
  --transforms transforms.json \
  --steps 15000 \
  --snapshot modelo.ingp
```

### 2. Generación de Pares LR/HR (render_pairs.py)
```bash
python3 render_pairs.py \
  --snapshot modelo.ingp \
  --out /ruta/escena \
  --lr 960 540 \
  --factor 2
```
Genera:
- `renders_lr/`: Imágenes en baja resolución
- `renders_hr/`: Imágenes en alta resolución

### 3. Entrenamiento Super-Resolución (train_sr.py)
```bash
python3 train_sr.py \
  --lr_dir /ruta/escena/renders_lr \
  --hr_dir /ruta/escena/renders_hr \
  --out modelo_sr.pth \
  --scale 2
```

## 🔄 Pipeline CI/CD

El Jenkinsfile automatiza el proceso completo:

1. **Build y Test**
   - Construcción de imagen Docker
   - Tests de integración
   - Publicación al registro

2. **Despliegue ArgoCD**
   ```yaml
   # Configuración Helm (values.yaml)
   job:
     image:
       repository: localhost:5000/nerf-trainer
       tag: v0.1.0
     
     resources:
       limits:
         nvidia.com/gpu: 1
       requests:
         cpu: 500m
         memory: 4Gi

     volume:
       pvcName: pvc-datos-nerf
       mountPath: /data

   training:
     steps: 15000
     superResolution:
       enabled: true
       scale: 2
       resolution:
         width: 960
         height: 540
   ```

### Características del Job:
- Política de reinicio: Never
- Pipeline completo: NeRF + Super-Resolución
- Soporte GPU vía nvidia-device-plugin
- Recursos optimizados para entrenamiento

## 🛠️ Uso Local

```bash
# Construir imagen
make build

# Ejecutar pipeline completo
make run SCENE=/data/mi-escena STEPS=15000 SR_SCALE=2

# Ejecutar pasos individualmente
make train-nerf SCENE=/data/mi-escena
make render-pairs SCENE=/data/mi-escena RES="960 540"
make train-sr SCENE=/data/mi-escena SCALE=2
```

### 📁 Estructura del Proyecto
```
/data/mi-escena/
├── input/
│   ├── transforms.json     # Parámetros de cámara (de COLMAP)
│   └── images/            # Imágenes originales
│       ├── 000.jpg
│       └── ...
├── models/
│   ├── nerf.ingp         # Modelo NeRF entrenado
│   └── sr_x2.pth         # Modelo de super-resolución
└── renders/
    ├── lr/               # Renders baja resolución
    └── hr/               # Renders alta resolución
```

## ☁️ Despliegue en Kubernetes

```bash
# Construir, publicar y desplegar
make release

# Solo actualizar valores de Helm
make update-values

# Forzar sync en ArgoCD
make sync
```

## 🔄 Pipeline de Release

1. Construye imagen Docker con soporte CUDA
2. Publica al registro de contenedores
3. Actualiza valores del chart de Helm
4. Sincroniza despliegue vía ArgoCD

## 📊 Monitoreo

### Métricas Disponibles
- **Entrenamiento NeRF**:
  - Pérdida de entrenamiento
  - PSNR (Peak Signal-to-Noise Ratio)
  - Uso de GPU/VRAM
  - Tiempo por iteración

- **Super-Resolución**:
  - Pérdida L1/L2
  - PSNR/SSIM por imagen
  - Métricas de calidad perceptual

### Interfaces
- Dashboard de ArgoCD (progreso del Job)
- Prometheus + Grafana (métricas GPU)
- Logs estructurados en Kubernetes

## 🔍 Troubleshooting

### Problemas Comunes

1. **Error de GPU:**
   ```
   Error: no NVIDIA GPU device is present
   ```
   - Verificar nvidia-device-plugin
   - Comprobar memoria GPU disponible
   - Validar compatibilidad CUDA

2. **Errores de Entrenamiento:**
   ```
   CUDA out of memory
   ```
   - Reducir resolución de entrenamiento
   - Ajustar batch size
   - Verificar ocupación de VRAM

3. **Super-Resolución:**
   ```
   Mismatch in image pairs
   ```
   - Verificar factor de escala
   - Comprobar integridad de renders
   - Validar resoluciones LR/HR
