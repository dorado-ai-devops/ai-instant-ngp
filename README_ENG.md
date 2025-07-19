# 🚀 ai-instant-ngp

NeRF (Neural Radiance Fields) trainer based on NVIDIA's [Instant-NGP](https://github.com/NVlabs/instant-ngp), CUDA-optimized and containerized for Kubernetes deployment.

## 🔧 Requirements

- Docker with NVIDIA support
- CUDA 11.8+
- Compatible GPU
- Kubernetes + ArgoCD (for deployment)
- Local container registry (default: localhost:5000)

## 📦 Structure

```
ai-instant-ngp/
├── Dockerfile          # Container with CUDA dependencies
├── Makefile           # Build and deployment scripts
└── data/              # Datasets directory
```

## 🛠️ Local Usage

```bash
# Build image
make build

# Run locally (mounts ./data)
make run
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

## 📊 Monitoring

Deployment can be monitored through:
- ArgoCD dashboard
- Kubernetes pod logs
- GPU metrics via Prometheus
