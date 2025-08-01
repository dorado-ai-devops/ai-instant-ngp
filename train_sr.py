#!/usr/bin/env python3
"""
train_sr.py  --lr_dir <carpeta renders_lr>  --hr_dir <carpeta renders_hr>
             --out <modelo.pth>             --scale 2|4
"""

import argparse, random, torch, torch.nn.functional as F
import torchvision.transforms as T
from torch.utils.data import Dataset, DataLoader
from pathlib import Path
from PIL import Image
from tqdm import tqdm
import sys

# ───────────── args ─────────────
p = argparse.ArgumentParser()
p.add_argument("--lr_dir", required=True)
p.add_argument("--hr_dir", required=True)
p.add_argument("--out",    required=True)
p.add_argument("--scale",  type=int, default=2)
p.add_argument("--epochs", type=int, default=120)
p.add_argument("--patch",  type=int, default=128)
p.add_argument("--batch",  type=int, default=16)
args = p.parse_args()

# ───────────── Dataset ──────────
class NerfSRDataset(Dataset):
    def __init__(self, lr_dir, hr_dir, patch):
        self.lr = sorted(Path(lr_dir).glob("*"))
        self.hr = sorted(Path(hr_dir).glob("*"))
        assert len(self.lr) == len(self.hr), "LR/HR mismatch"
        self.patch = patch
        self.to_tensor = T.ToTensor()

    def __len__(self): return len(self.lr)

    def __getitem__(self, idx):
        lr = self.to_tensor(Image.open(self.lr[idx]).convert("RGB"))
        hr = self.to_tensor(Image.open(self.hr[idx]).convert("RGB"))
        _, h, w = lr.shape
        x = random.randint(0, w - self.patch)
        y = random.randint(0, h - self.patch)
        lr_patch = lr[:, y:y+self.patch, x:x+self.patch]
        s = args.scale
        hr_patch = hr[:, y*s:(y+self.patch)*s, x*s:(x+self.patch)*s]
        return lr_patch, hr_patch

ds = NerfSRDataset(args.lr_dir, args.hr_dir, patch=args.patch)
loader = DataLoader(ds, batch_size=args.batch, shuffle=True, num_workers=4)

#EDSR local ─────────────

sys.path.append("/app/edsr/src")

from option import args as edsr_args
from model import make_model


edsr_args.scale = [args.scale]
edsr_args.model = "EDSR"
edsr_args.n_resblocks = 8      
edsr_args.n_feats = 64
edsr_args.res_scale = 1
edsr_args.rgb_range = 255
edsr_args.n_colors = 3
edsr_args.no_upsampling = False
edsr_args.ext = "img"
edsr_args.pre_train = ""

model = make_model(edsr_args).cuda()
opt = torch.optim.Adam(model.parameters(), 1e-4)

# Entrenar ─────────────
print(f"Entrenando SR ({len(loader)} batches/epoch, {args.epochs} epochs)")
for epoch in range(args.epochs):
    pbar = tqdm(loader, leave=False)
    for lr, hr in pbar:
        lr, hr = lr.cuda(), hr.cuda()
        sr = model(lr)
        loss = F.l1_loss(sr, hr)
        opt.zero_grad(); loss.backward(); opt.step()
        pbar.set_description(f"ep {epoch:03d}  L1 {loss.item():.4f}")

torch.save(model.state_dict(), args.out)
print("SR guardado en", args.out)
