# 🚀 ai-instant-ngp

NeRF (Neural Radiance Fields) trainer based on NVIDIA's [Instant-NGP](https://github.com/NVlabs/instant-ngp), CUDA-optimized and containerized for Kubernetes deployment.

## 🔧 Requirements

- Docker with NVIDIA support
- CUDA 11.8+
- Compatible GPU
- Kubernetes + ArgoCD (for deployment)
- Local container registry (default: localhost:5000)

## 📦 Estructura

```
ai-instant-ngp/
├── Dockerfile          # Contenedor con dependencias CUDA
├── Makefile           # Scripts de build y despliegue
└── data/              # Directorio para datasets
```

## 🐋 Dockerfile Details

The container is based on CUDA 11.8 and sets up a headless environment for training:

```dockerfile
# CUDA Base
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# Instant-NGP Dependencies
- CMake and build tools
- OpenGL and X11 libraries
- Python 3 with headless support (xvfb)

# Instant-NGP Setup
- Version: 2.0 (stable tag)
- Mode: nerf (Neural Radiance Fields)
- Build: RelWithDebInfo with Ninja

# Entrypoint
Configured to run in NeRF mode with headless support (entrypoint.sh):
/app/instant-ngp/build/instant-ngp --mode nerf --no-gui --scene $DATA_PATH
```

## ⚙️ Helm Chart

The chart deploys a Kubernetes Job with the following features:

```yaml
# Default configuration (values.yaml)
image:
  repository: localhost:5000/nerf-trainer
  tag: v0.1.0

resources:
  limits:
    nvidia.com/gpu: 1
  requests:
    cpu: 500m
    memory: 1Gi

volume:
  pvcName: pvc-datos-nerf
  mountPath: /data

# Dataset path
scenePath: /data/fox
```

### Job Features:
- Restart Policy: Never
- PVC mounting for datasets
- GPU support via nvidia-device-plugin
- Guaranteed resources (CPU/memory/GPU)

## 🛠️ Local Usage

```bash
# Build image
make build

# Run locally (mounts ./data)
make run

# Example running with specific dataset
docker run --rm -v $(PWD)/data:/data --gpus all nerf-trainer:v0.1.0 /data/my-scene
```

### 📁 Data Structure
The container expects to find training images in the mounted directory:

```
/data/
└── my-scene/
    ├── transforms.json    # Camera parameters
    └── images/           # Training images
        ├── 000.jpg
        ├── 001.jpg
        └── ...
```

## ☁️ Kubernetes Deployment

```bash
# Build, publish and deploy
make release

# Only update Helm values
make update-values

# Force ArgoCD sync
make sync
```

## 🔄 Release Pipeline

1. Builds Docker image with CUDA support
2. Publishes to container registry
3. Updates Helm chart values
4. Syncs deployment via ArgoCD

## 📊 Monitoreo

El despliegue puede monitorearse a través de:
- Dashboard de ArgoCD
- Logs del pod en Kubernetes
- Métricas de GPU vía Prometheus

## 🔍 Troubleshooting

### Common Issues

1. **GPU Not Available Error:**
   ```
   Error: no NVIDIA GPU device is present
   ```
   - Verify nvidia-device-plugin is installed in the cluster
   - Check resource limits in values.yaml

2. **Volume Error:**
   ```
   Unable to mount volumes: pvc "pvc-datos-nerf" not found
   ```
   - Ensure the PVC specified in values.yaml exists
   - Check volume access permissions

3. **Dataset Error:**
   ```
   Scene 'X' does not exist
   ```
   - Verify the dataset path exists in the PVC
   - Check dataset structure (transforms.json + images/)
