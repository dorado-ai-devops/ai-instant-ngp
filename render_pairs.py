#!/usr/bin/env python3
"""
render_pairs.py --snapshot model_lr.ingp --out /data/scene --lr 960 540 --factor 2
Produce renders_lr/  &  renders_hr/
"""
import argparse, subprocess, pathlib
p = argparse.ArgumentParser()
p.add_argument('--snapshot'); p.add_argument('--out')
p.add_argument('--lr', nargs=2, type=int); p.add_argument('--factor', type=int, default=2)
a = p.parse_args()

out = pathlib.Path(a.out)
lr_dir = out / 'renders_lr'
hr_dir = out / 'renders_hr'
lr_dir.mkdir(exist_ok=True); hr_dir.mkdir(exist_ok=True)

# ----- Low‑res renders -------------------------------------------------
subprocess.check_call([
    "python3", "/app/instant-ngp/scripts/run.py",
    "--snapshot", a.snapshot,
    "--mode", "render_train_split",          # ← cambio
    "--render_res", str(a.lr[0]), str(a.lr[1]),
    "--save_images", str(lr_dir)
])

# ----- High‑res renders ------------------------------------------------
subprocess.check_call([
    "python3", "/app/instant-ngp/scripts/run.py",
    "--snapshot", a.snapshot,
    "--mode", "render_train_split",          # ← cambio
    "--render_res", str(a.lr[0]*a.factor), str(a.lr[1]*a.factor),
    "--save_images", str(hr_dir)
])
