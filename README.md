# 🌐 ai-instant-ngp

Este proyecto proporciona un **entrenador de NeRF basado en Instant‑NGP** (​CUDA) preparado para flujos DevOps en contenedores y orquestado con *Helm + Argo CD*.

This project delivers a **CUDA‑optimised Instant‑NGP NeRF trainer** ready for DevOps container workflows and orchestrated with *Helm + Argo CD*.

---
## 🧩 Características / Features

|              | 🇪🇸 Español | 🇺🇸 English |
|--------------|-----------|------------|
| Entrenamiento NeRF (HR / FastSR‑NeRF) | ✔ | ✔ |
| Súper‑resolución x2/x4 (EDSR tiny)    | ✔ | ✔ |
| Pipeline CI / CD (Docker → Jenkins → Argo CD) | ✔ | ✔ |
| Despliegue GPU en Kubernetes          | ✔ | ✔ |

*Optimizado para CUDA 12.9 – compatible con GPUs RTX Ampere y superior.*

---
## 📦 Estructura mínima

```text
ai-instant-ngp/
├── Dockerfile            # Imagen CUDA 12.9 con PyTorch, Instant‑NGP
├── charts/               # Helm chart para Job/Deployment
├── entrypoint.sh         # Orquestra entrenamiento completo
├── train_ngp.py          # NeRF training (HR o LR)
├── render_pairs.py       # Crea pares LR/HR para SR
├── train_sr.py           # Fine‑tune super‑resolution
└── README.md             # Este archivo
```

---
## 🔧 Requisitos  /  Requirements

* NVIDIA Docker ↔ nvidia‑container‑toolkit  
* CUDA ≥ 12.9, Driver 540+  
* Kubernetes 1.28 + nvidia‑device‑plugin  
* Docker registry (default `localhost:5000`)

---
## 🔄 Pipeline rápido (CLI)

```bash
# 1. Build & push
make build

# 2. Ejecutar NeRF HR (clásico)
make train-nerf   SCENE=/data/scene

# 3. Ejecutar FastSR‑NeRF completo (LR + SR)
make run          SCENE=/data/scene STEPS=8000 SR_SCALE=2 FAST=1
```

---
## 📚 Documentación completa

* 🇪🇸 **[Guía en Español](./README_ES.md)** – despliegue local, CI/CD y troubleshooting.  
* 🇺🇸 **[English Guide](./README_ENG.md)** – local run, CI/CD pipeline and troubleshooting.

---
© 2025 Daniel Dorado (@dorado‑ai‑devops)
