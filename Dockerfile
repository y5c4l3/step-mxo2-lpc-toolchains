FROM ubuntu:jammy AS base

ARG PRJTRELLIS_COMMIT="36c615d1740473cc3574464c7f0bed44da20e5b6"
ARG YOSYS_COMMIT="3d9e44d18227c136cea031c667a5158fe31ac996"
ARG NEXTPNR_COMMIT="4220ce100776381fcaed4ceb2efed722e7ddf474"

RUN apt-get update && TZ=Asia/Shanghai DEBIAN_FRONTEND=noninteractive \
    apt-get -y install cmake clang-format libboost-all-dev build-essential \
    wget libeigen3-dev clang bison flex libreadline-dev \
    gawk tcl-dev libffi-dev git graphviz xdot pkg-config python3 \
    libboost-system-dev libboost-python-dev libboost-filesystem-dev zlib1g-dev \
    python3-setuptools python3-serial && \
    rm -rf /var/lib/apt/lists/*

RUN git config --global user.name "y5c4l3" && git config --global user.email "y5c4l3@proton.me"

RUN mkdir /build && cd /build && git clone --recursive -b jed https://github.com/cr1901/prjtrellis.git && \
    cd prjtrellis && \
    git remote add upstream https://github.com/YosysHQ/prjtrellis.git && \
    git fetch upstream master && \
    git merge --no-edit ${PRJTRELLIS_COMMIT} && \
    git submodule update --init --recursive && \
    cd /build/prjtrellis/libtrellis && cmake -DCMAKE_INSTALL_PREFIX=/usr/local . && make -j8 && make install && \
    rm -rf /build/prjtrellis

RUN cd /build && git clone --recursive https://github.com/YosysHQ/yosys.git && \
    cd yosys && git reset --hard ${YOSYS_COMMIT} && git submodule update --init --recursive && \
    cd /build/yosys && make config-gcc && make -j8 && make install && \
    rm -rf /build/yosys

RUN cd /build && git clone --recursive https://github.com/YosysHQ/nextpnr.git && \
    cd nextpnr && git reset --hard ${NEXTPNR_COMMIT} && git submodule update --init --recursive && \
    cd /build/nextpnr && cmake -DARCH='machxo2' -DMACHXO2_DEVICES='4000' . && make -j8 && make install && \
    rm -rf /build/nextpnr && rm -rf /build

RUN apt-get -y autoremove clang clang-14 clang-format cmake build-essential gcc-11

WORKDIR "/root"

FROM scratch
COPY --from=0 / /
