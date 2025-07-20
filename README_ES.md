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

## 🐋 Detalles del Dockerfile

El contenedor está basado en CUDA 11.8 y configura un entorno headless para entrenamiento:

```dockerfile
# Base CUDA
FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# Dependencias para Instant-NGP
- CMake y herramientas de build
- Librerías OpenGL y X11
- Python 3 con soporte headless (xvfb)

# Configuración Instant-NGP
- Versión: 2.0 (tag estable)
- Modo: nerf (Neural Radiance Fields)
- Build: RelWithDebInfo con Ninja

# Entrypoint
Configurado para ejecutar en modo NeRF y headless (entrypoint.sh):
/app/instant-ngp/build/instant-ngp --mode nerf --no-gui --scene $DATA_PATH
```

## ⚙️ Helm Chart

El chart despliega un Job de Kubernetes con las siguientes características:

```yaml
# Configuración por defecto (values.yaml)
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

# Ruta del dataset
scenePath: /data/fox
```

### Características del Job:
- Política de reinicio: Never
- Montaje de PVC para datasets
- Soporte GPU vía nvidia-device-plugin
- Recursos garantizados (CPU/memoria/GPU)

## 🛠️ Uso Local

```bash
# Construir imagen
make build

# Ejecutar localmente (monta ./data)
make run

# Ejemplo de ejecución con dataset específico
docker run --rm -v $(PWD)/data:/data --gpus all nerf-trainer:v0.1.0 /data/mi-escena
```

### 📁 Estructura de Datos
El contenedor espera encontrar las imágenes de entrenamiento en el directorio montado:

```
/data/
└── mi-escena/
    ├── transforms.json    # Parámetros de cámara
    └── images/           # Imágenes para entrenamiento
        ├── 000.jpg
        ├── 001.jpg
        └── ...
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

## 🔍 Troubleshooting

### Problemas Comunes

1. **Error de GPU no disponible:**
   ```
   Error: no NVIDIA GPU device is present
   ```
   - Verificar que nvidia-device-plugin está instalado en el cluster
   - Comprobar límites de recursos en values.yaml

2. **Error de volumen:**
   ```
   Unable to mount volumes: pvc "pvc-datos-nerf" not found
   ```
   - Asegurar que existe el PVC especificado en values.yaml
   - Verificar permisos de acceso al volumen

3. **Error de dataset:**
   ```
   Scene 'X' does not exist
   ```
   - Comprobar que el path donde estan el dataset existe en el PVC
   - Verificar estructura del dataset (transforms.json + images/)
