FROM nvidia/cuda:12.9.0-devel-ubuntu22.04

# ───────────────── system deps ─────────────────
RUN apt-get update && apt-get install -y \
    git cmake build-essential libgl1-mesa-dev libx11-dev \
    libxi-dev libxrandr-dev libxinerama-dev libxcursor-dev libglew-dev \
    wget unzip ninja-build libpng-dev libjpeg-dev \
    python3 python3-pip xvfb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ───────────────── instant‑ngp ─────────────────
RUN git clone --recursive https://github.com/NVlabs/instant-ngp.git
WORKDIR /app/instant-ngp
RUN git checkout tags/v2.0 -b build-v2.0 && \
    git submodule update --init --recursive
RUN sed -i 's|cam_matrix = f.get("transform_matrix", f\["transform_matrix_start"\])|cam_matrix = f.get("transform_matrix") or f.get("transform_matrix_start")|' scripts/run.py
# ───────────────── Python deps ─────────────────
RUN pip3 install "numpy<2"
RUN pip3 install --upgrade pip && pip3 install -r requirements.txt \
 && pip3 install commentjson tqdm

# ───────────────── PyTorch GPU ─────────────────
RUN pip3 install --extra-index-url https://download.pytorch.org/whl/cu121 \
    torch==2.2.0+cu121 torchvision==0.17.0+cu121 einops

# ───────────────── Build instant‑ngp ─────────────────
RUN cmake . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DUSE_CUDA=ON -G Ninja && \
    cmake --build build --target instant-ngp pyngp -j12

# ───────────────── Entrypoint ─────────────────
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY render_pairs.py /app/render_pairs.py

COPY train_sr.py /app/train_sr.py

COPY train_ngp.py /app/train_ngp.py

ENTRYPOINT ["/entrypoint.sh"]
