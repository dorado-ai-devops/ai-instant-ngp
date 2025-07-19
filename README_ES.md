# 🚀 ai-instant-ngp

Entrenador de NeRF (Neural Radiance Fields) basado en [Instant-NGP](https://github.com/NVlabs/instant-ngp) de NVIDIA, optimizado para CUDA y containerizado para despliegue en Kubernetes.

## 🔧 Requisitos

- Docker con soporte NVIDIA
- CUDA 11.8+
- GPU compatible
- Kubernetes + ArgoCD (para despliegue)
- Registro de contenedores local (default: localhost:5000)

## 📦 Estructura

```
ai-instant-ngp/
├── Dockerfile          # Contenedor con dependencias CUDA
├── Makefile           # Scripts de build y despliegue
└── data/              # Directorio para datasets
```

## 🛠️ Uso Local

```bash
# Construir imagen
make build

# Ejecutar localmente (monta ./data)
make run
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

El despliegue puede monitorearse a través de:
- Dashboard de ArgoCD
- Logs del pod en Kubernetes
- Métricas de GPU vía Prometheus
