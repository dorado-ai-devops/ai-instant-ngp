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


transforms_path = str(out / 'transforms_lr.json')  

# LOW RES
subprocess.check_call([
    "python3", "/app/instant-ngp/scripts/run.py",
    "--load_snapshot", a.snapshot,
    "--screenshot_transforms", transforms_path,
    "--screenshot_dir", str(lr_dir),
    "--width", str(a.lr[0]), "--height", str(a.lr[1]),
    "--screenshot_spp", "8"
])

# HIGH RES
subprocess.check_call([
    "python3", "/app/instant-ngp/scripts/run.py",
    "--load_snapshot", a.snapshot,
    "--screenshot_transforms", transforms_path,
    "--screenshot_dir", str(hr_dir),
    "--width", str(a.lr[0]*a.factor), "--height", str(a.lr[1]*a.factor),
    "--screenshot_spp", "8"
])
