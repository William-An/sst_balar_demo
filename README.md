# SST Balar Demo

A demo repo to showcase SST <---> GPGPU-Sim integration

## From dockerhub

```bash
docker pull williammtk/sst_balar_demo

docker run -it williammtk/sst_balar_demo
```

## From source

```bash
docker build . --file Dockerfile --tag williammtk/sst_balar_demo

docker run -it williammtk/sst_balar_demo
```

## Example scripts

1. `show_traces.sh`: print program and its CUDA API traces
2. `run_sst_test.sh`: run SST test on Balar
3. `run_trace_mode.sh`: Run vectorAdd program from traces
