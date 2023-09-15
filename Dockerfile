# syntax=docker/dockerfile:1
FROM nvidia/cuda:11.0.3-devel-ubuntu20.04

# Change to Bash
SHELL ["/bin/bash", "-c"]

# Env setup
ENV DEBIAN_FRONTEND=noninteractive 
ENV CUDA_INSTALL_PATH=/usr/local/cuda
ENV LD_LIBRARY_PATH=$CUDA_INSTALL_PATH/lib64:$LD_LIBRARY_PATH

# Dependencies
RUN apt-get update -y
RUN apt-get install -y git
# GPGPU-Sim deps
RUN apt-get install -y build-essential xutils-dev bison zlib1g-dev flex libglu1-mesa-dev
# SST deps
RUN apt install -y openmpi-bin openmpi-common libtool libtool-bin autoconf python3 python3-dev automake build-essential git 

# Prepare SST and GPGPU-Sim
RUN git clone https://github.com/sstsimulator/sst-core.git
RUN git clone https://github.com/sstsimulator/sst-elements.git
RUN git clone -b sst-integration https://github.com/William-An/gpgpu-sim_distribution.git

# Build GPGPU-Sim and SST
RUN cd gpgpu-sim_distribution \
    && source ./setup_environment \
    && make -j $(nproc)
RUN cd sst-core \
    && ./autogen.sh \
    && ./configure --prefix=`realpath ../sstcore-install` --disable-mpi --disable-mem-pools \
    && make -j $(nproc) \
    && make install
RUN source ./gpgpu-sim_distribution/setup_environment \
    && cd sst-elements \
    && ./autogen.sh \
    && ./configure --prefix=`realpath ../sstelements-install` --with-sst-core=`realpath ../sstcore-install` --with-cuda=$CUDA_INSTALL_PATH --with-gpgpusim=$GPGPUSIM_ROOT \
    && make -j $(nproc) \
    && make install

# Prep for demo
RUN apt-get install -y xxd

# Run commands in shell script
COPY --chmod=777 run_sst_test.sh run_trace_mode.sh \
                 run_vanadis_mode.sh show_traces.sh /
