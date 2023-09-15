#! /bin/bash

source /gpgpu-sim_distribution/setup_environment
cd /sst-elements/src/sst/elements/balar/tests/
make -C vectorAdd
/sstcore-install/bin/sst testBalar-testcpu.py --model-options='-c gpu-v100-mem.cfg -v -x ./vectorAdd/vectorAdd -t ./vectorAdd/cuda_calls.trace'