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

# Run commands in shell script
RUN echo "source /gpgpu-sim_distribution/setup_environment \
    && /sstcore-install/bin/sst-test-elements -p /sst-elements/src/sst/elements/balar/tests" > /run_sst_test.sh
RUN echo "source /gpgpu-sim_distribution/setup_environment \
    && cd /sst-elements/src/sst/elements/balar/tests/ \
    && make -C vectorAdd \
    && /sstcore-install/bin/sst testBalar-testcpu.py --model-options='-c gpu-v100-mem.cfg -v -x ./vectorAdd/vectorAdd -t ./vectorAdd/cuda_calls.trace'" > /run_trace_mode.sh
RUN echo "source /gpgpu-sim_distribution/setup_environment \
    && cd /sst-elements/src/sst/elements/balar/tests/ \
    && /sstcore-install/bin/sst testBalar-vanadis.py --model-options='-c gpu-v100-mem.cfg'" > /run_vanadis_mode.sh
RUN chmod +x /run_sst_test.sh 
RUN chmod +x /run_trace_mode.sh 

# Need to fix vanadis mode later
# RUN chmod +x /run_vanadis_mode.sh 