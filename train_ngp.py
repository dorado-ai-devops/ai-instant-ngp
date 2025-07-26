#!/usr/bin/env python3
import argparse, subprocess, os, sys
parser = argparse.ArgumentParser()
parser.add_argument('--data', required=True)
parser.add_argument('--steps', type=int, default=15000)
parser.add_argument('--snapshot', required=True)
args = parser.parse_args()

cmd = [
    "python3", "/app/instant-ngp/scripts/run.py",
    "--scene", args.data,
    "--n_steps", str(args.steps),
    "--save_snapshot", args.snapshot,
]
print("NGP CMD:", " ".join(cmd)); sys.stdout.flush()
subprocess.check_call(cmd)


