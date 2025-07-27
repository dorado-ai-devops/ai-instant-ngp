FROM nvidia/cuda:12.9.0-devel-ubuntu22.04


RUN apt-get update && apt-get install -y \
    git cmake build-essential libgl1-mesa-dev libx11-dev \
    libxi-dev libxrandr-dev libxinerama-dev libxcursor-dev libglew-dev \
    wget unzip ninja-build libpng-dev libjpeg-dev \
    python3 python3-pip python3-venv xvfb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone https://github.com/thstkdgus35/EDSR-PyTorch.git edsr

RUN git clone --recursive https://github.com/dorado-ai-devops/instant-ngp.git
WORKDIR /app/instant-ngp
RUN git checkout fix-transform-matrix-keyerror && git submodule update --init --recursive


RUN pip3 install --upgrade pip && pip3 install -r requirements.txt \
 && pip3 install commentjson tqdm


# ───── PyTorch venv aislado por numpy<2.0 ─────
RUN python3 -m venv /venv_sr && \
    /venv_sr/bin/pip install --upgrade pip && \
    /venv_sr/bin/pip install --extra-index-url https://download.pytorch.org/whl/cu121 \
        torch==2.2.0+cu121 torchvision==0.17.0+cu121 einops && \
    /venv_sr/bin/pip install "numpy<2" pillow tqdm


RUN cmake . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DUSE_CUDA=ON -G Ninja && \
    cmake --build build --target instant-ngp pyngp -j12


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY render_pairs.py /app/render_pairs.py

COPY train_sr.py /app/train_sr.py

COPY train_ngp.py /app/train_ngp.py

ENTRYPOINT ["/entrypoint.sh"]
