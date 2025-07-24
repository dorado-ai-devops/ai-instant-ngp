FROM nvidia/cuda:12.9.0-devel-ubuntu22.04


RUN apt-get update && apt-get install -y \
    git cmake build-essential libgl1-mesa-dev libx11-dev libxi-dev \
    libxrandr-dev libxinerama-dev libxcursor-dev libglew-dev \
    wget unzip ninja-build libpng-dev libjpeg-dev \
    python3 python3-pip xvfb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


WORKDIR /app


RUN git clone --recursive https://github.com/NVlabs/instant-ngp.git
WORKDIR /app/instant-ngp
RUN git checkout tags/v2.0 -b build-v2.0 && \
    git submodule update --init --recursive


RUN pip3 install --upgrade pip && pip3 install -r requirements.txt
RUN pip3 install commentjson numpy tqdm

RUN cmake . -B build \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DUSE_CUDA=ON \
    -G Ninja && \
    cmake --build build --target instant-ngp pyngp -j12

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
