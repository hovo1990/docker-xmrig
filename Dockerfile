FROM nvidia/cuda:11.2.0-devel AS build
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -q -y update && \
    apt-get -q -y upgrade && \
    apt-get -q -y install \
    git \
    build-essential \
    cmake \
    libuv1-dev \
    libssl-dev \
    libhwloc-dev
RUN git clone --depth 1 https://github.com/xmrig/xmrig.git /tmp/xmrig
WORKDIR /tmp/xmrig/build
RUN cmake .. -DWITH_CUDA=ON -DWITH_PROFILING=OFF -DWITH_BENCHMARK=ON \
    -DWITH_DEBUG_LOG=OFF -DHWLOC_DEBUG=OFF -DWITH_MSR=OFF && \
    make -j$(nproc)
RUN git clone --depth 1 https://github.com/xmrig/xmrig-cuda.git /tmp/xmrig-cuda
WORKDIR /tmp/xmrig-cuda/build
RUN cmake .. -DCUDA_LIB=/usr/local/cuda/lib64/stubs/libcuda.so \
    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda && \
    make -j$(nproc)

FROM nvidia/cuda:11.2.0-runtime
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -q -y update && \
    apt-get -q -y upgrade && \
    apt-get -q -y install \
    libuv1 \
    libssl1.1 \
    libhwloc15
WORKDIR /opt/xmrig
COPY --from=build /tmp/xmrig/build/xmrig /opt/xmrig
COPY --from=build /tmp/xmrig-cuda/build/libxmrig-cuda.so /opt/xmrig
RUN ln -sf /opt/xmrig/libxmrig-cuda.so /opt/xmrig/libxmrig-cuda.so.1
ENTRYPOINT ["/opt/xmrig/xmrig"]
