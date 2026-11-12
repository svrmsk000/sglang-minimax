# MiniMax H3 SGLang service image

A small extension of `lmsysorg/sglang:latest` that adds a SysV-style `sgmax` service and the MiniMax H3 Ref2VA launcher.

The image does not install another SGLang environment and does not bake model weights. It uses the `sglang` executable already supplied by the base image (resolved from `PATH` at runtime).

## Build

```bash
docker build -t sglang-minimax:latest .
```

## Run

```bash
docker run -d --name sglang-minimax --gpus all --ipc=host --shm-size 32g \
  -p 30010:30010 \
  -v /workspace/huggingface:/workspace/runpod-slim/huggingface \
  -e HF_TOKEN \
  sglang-minimax:latest sleep infinity
```

The example volume keeps downloaded Hugging Face files outside the container. Change the host path as needed.

## Service commands

Run inside the container as root:

```bash
service sgmax 1 start
service sgmax 2 start
service sgmax 4 start
service sgmax status
service sgmax stop
```

Stop the current mode before starting another GPU mode.

## GPU profiles

| GPUs | Parallel arguments | DiT resident layers | Video VAE resident layers | Prefetch |
|---:|---|---:|---:|---|
| 1 | none | 4 | 24 | none |
| 2 | `--tp-size 2 --ulysses-degree 1 --encoder-parallel auto` | 20 | 36 | `--dit-offload-prefetch-size 1` |
| 4 | `--tp-size 2 --ulysses-degree 2 --encoder-parallel auto` | 20 | 36 | `--dit-offload-prefetch-size 1` |

These profiles match `sglang/start_minimax_h3_ref2va.sh` from the source branch `feat/comfyui-extra-model-setup-scripts`.

## Environment

- `SGLANG_BIN`: optional path to the SGLang executable; defaults to `command -v sglang`.
- `MINIMAX_H3_SGLANG_MODEL_ID`: model ID or local model path; default `MiniMaxAI/MiniMax-H3`.
- `HF_HOME`: Hugging Face cache; default `/workspace/runpod-slim/huggingface`.
- `HF_TOKEN`: Hugging Face token, if required by model access.
- `SGLANG_HOST` / `SGLANG_PORT`: bind address and port; defaults `0.0.0.0` / `30010`.
- `SGLANG_EXTRA_ARGS`: additional whitespace-separated arguments passed to `sglang serve`.
- `SGLANG_LOGFILE`: service log; default `/workspace/runpod-slim/logs/sglang.log`.
- `SGLANG_PIDFILE` / `SGLANG_MODEFILE`: service state files; defaults `/run/sgmax.pid` and `/run/sgmax.gpus`.
- `SGLANG_DIT_RESIDENT_LAYERS`: 1-GPU DiT resident layers; default `4`.
- `SGLANG_VIDEO_VAE_RESIDENT_LAYERS`: shared Video VAE resident-layer override.
- `SGLANG_VIDEO_VAE_RESIDENT_LAYERS_1GPU`: 1-GPU Video VAE override; default `24`.
- `SGLANG_DIT_RESIDENT_LAYERS_2GPU` / `SGLANG_DIT_RESIDENT_LAYERS_4GPU`: defaults `20`.
- `SGLANG_VIDEO_VAE_RESIDENT_LAYERS_2GPU` / `SGLANG_VIDEO_VAE_RESIDENT_LAYERS_4GPU`: defaults `36`.
- `SGLANG_WARMUP_RESOLUTIONS`: default `1344x768`.
- `SGLANG_WARMUP_NUM_FRAMES`: default `24`.
- `PYTORCH_CUDA_ALLOC_CONF`: default `expandable_segments:True`.
- `CUDA_HOME`: default `/usr/local/cuda`.

Model weights are downloaded on first start by SGLang into `HF_HOME`; mount that directory to persist the cache.

## Notes

- The service starts only when explicitly requested; the container does not auto-start MiniMax H3.
- The image build checks that `sglang` and `service` are available and validates shell syntax. It does not perform a GPU/model-download smoke test.
