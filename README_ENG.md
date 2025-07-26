# 🚀 ai-instant-ngp

Neural Radiance Field (NeRF) trainer based on NVIDIA’s [Instant‑NGP](https://github.com/NVlabs/instant-ngp), CUDA‑optimized and container‑ready for Kubernetes deployment. Includes a full NeRF training pipeline plus FastSR‑NeRF (low‑res NeRF + super‑resolution).

## 🔧 Requirements

* Docker with NVIDIA runtime  
* CUDA 12.9+  
* Compatible GPU  
* Kubernetes + Argo CD (for deployment)  
* Local container registry (default: `localhost:5000`)

## 📦 Project Layout

```
ai-instant-ngp/
├── Dockerfile          # CUDA image with all deps
├── Makefile            # Build & deploy scripts
├── Jenkinsfile         # CI/CD pipeline
├── entrypoint.sh       # Container entry script
├── train_ngp.py        # NeRF training
├── render_pairs.py     # Generate LR/HR pairs
└── train_sr.py         # Super‑resolution training
```

## 🤖 Training Pipeline

The complete process has three phases:

### 1. NeRF Training (`train_ngp.py`)
```bash
python3 train_ngp.py   --data /path/scene   --transforms transforms.json   --steps 15000   --snapshot model.ingp
```

### 2. LR/HR Pair Generation (`render_pairs.py`)
```bash
python3 render_pairs.py   --snapshot model.ingp   --out /path/scene   --lr 960 540   --factor 2
```
Creates  
* `renders_lr/` – low‑res renders  
* `renders_hr/` – high‑res renders

### 3. Super‑Resolution Training (`train_sr.py`)
```bash
python3 train_sr.py   --lr_dir /path/scene/renders_lr   --hr_dir /path/scene/renders_hr   --out sr_model.pth   --scale 2
```

## 🔄 CI/CD Pipeline

`Jenkinsfile` automates:

1. **Build & Test**  
   * Build Docker image  
   * Integration tests  
   * Push to registry
2. **Argo CD Deploy**
   ```yaml
   # Helm values.yaml
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
       pvcName: pvc-nerf-data
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

### Job Highlights
* Restart policy: **Never**  
* End‑to‑end NeRF + SR inside the Job  
* GPU via `nvidia-device-plugin`  
* Resource‑optimized for training

### 📁 Dataset Layout
```
/data/my-scene/
├── input/
│   ├── transforms.json   # Camera params (from COLMAP)
│   └── images/
│       ├── 000.jpg
│       └── ...
├── models/
│   ├── nerf.ingp         # Trained NeRF
│   └── sr_x2.pth         # Super‑resolution model
└── renders/
    ├── lr/               # Low‑res renders
    └── hr/               # High‑res renders
```

## ☁️ Kubernetes Deployment

```bash
# Build, push and deploy
make release

# Patch Helm values only
make update-values

# Force sync in Argo CD
make sync
```

## 🔄 Release Pipeline

1. Build CUDA image  
2. Push to container registry  
3. Update Helm chart values  
4. Sync deployment through Argo CD

## 📊 Monitoring

### Metrics
* **NeRF Training**
  * Training loss
  * PSNR
  * GPU/VRAM usage
  * Iteration time
* **Super‑Resolution**
  * L1/L2 loss
  * PSNR/SSIM per image
  * Perceptual quality scores

### Interfaces
* Argo CD dashboard (Job progress)
* Prometheus + Grafana (GPU metrics)
* Structured Kubernetes logs

## 🔍 Troubleshooting

| Issue | Fix |
|-------|-----|
| **GPU error**<br>`no NVIDIA GPU device is present` | Check `nvidia-device-plugin`, free GPU memory, validate CUDA version |
| **Training OOM**<br>`CUDA out of memory` | Lower training resolution, reduce batch size, monitor VRAM |
| **SR mismatch**<br>`Mismatch in image pairs` | Verify scale factor, check renders integrity, validate LR/HR resolutions |
