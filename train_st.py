#!/usr/bin/env python3
"""
train_sr.py --lr_dir renders_lr --hr_dir renders_hr --out sr_model.pth --scale 2
"""
import argparse, torch, torchvision.transforms as T, torch.nn.functional as F
from torch.utils.data import DataLoader,Dataset
from pathlib import Path, PosixPath
import random, einops, tqdm, os, sys

p=argparse.ArgumentParser()
p.add_argument('--lr_dir'); p.add_argument('--hr_dir')
p.add_argument('--out'); p.add_argument('--scale',type=int,default=2)
a=p.parse_args()

class PairDS(Dataset):
    def __init__(s,lr,hr,patch=128):
        s.lr=sorted(Path(lr).glob('*')); s.hr=sorted(Path(hr).glob('*'))
        s.patch=patch
    def __len__(s): return len(s.lr)
    def __getitem__(s,i):
        lt=T.ToTensor()(T.functional.pil_to_image(open(s.lr[i],'rb')))
        ht=T.ToTensor()(T.functional.pil_to_image(open(s.hr[i],'rb')))
        _,h,w=lt.shape; x=random.randint(0,w-s.patch); y=random.randint(0,h-s.patch)
        return lt[:,y:y+s.patch,x:x+s.patch], ht[:,y*a.scale:(y+s.patch)*a.scale,x*a.scale:(x+s.patch)*a.scale]

ds=PairDS(a.lr_dir,a.hr_dir); dl=DataLoader(ds,batch_size=16,shuffle=True,num_workers=4)
model=torch.hub.load('eugenesiow/edsr-pytorch','edsr',pretrained=False,scale=a.scale,tiny=True).cuda()
opt=torch.optim.Adam(model.parameters(),1e-4)
for epoch in range(120):
  for lr,hr in dl:
    lr,hr=lr.cuda(),hr.cuda(); sr=model(lr)
    loss=F.l1_loss(sr,hr); opt.zero_grad(); loss.backward(); opt.step()
torch.save(model.state_dict(),a.out)
print("SR saved",a.out)
