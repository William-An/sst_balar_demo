#! /bin/bash

source /gpgpu-sim_distribution/setup_environment
cd /sst-elements/src/sst/elements/balar/tests/
/sstcore-install/bin/sst testBalar-vanadis.py --model-options='-c gpu-v100-mem.cfg'