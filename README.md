# MiniMax H3 SGLang + ComfyUI image

A small extension of `lmsysorg/sglang:latest` that adds the MiniMax H3 Ref2VA SGLang launcher, SSH access, and an isolated ComfyUI 0.42 environment.

SGLang continues to use the Python environment supplied by the base image. ComfyUI is installed separately in `/opt/comfyui-venv`; its packages are installed into that venv only. The ComfyUI venv reuses the base image's CUDA-enabled PyTorch and torchvision by adding the base environment's site-packages path to the ComfyUI venv, so the Docker build does not install or replace a second PyTorch/CUDA stack in the SGLang environment.

Pinned components:

- ComfyUI: `v0.42.1`
- ComfyUI-Manager: `4.2.2`
- ComfyUI directory: `/opt/ComfyUI`
- ComfyUI Python environment: `/opt/comfyui-venv`

The image does not bake model weights. It includes the MiniMax H3 Prompt Writer and H3 Video Upsampler custom nodes, plus CUDA-enabled `llama-cpp-python`.

## Build

```bash
docker build -t sglang-minimax:comfyui-0.42 .
```

## Run

```bash
docker run -d --name sglang-minimax --gpus all --ipc=host --shm-size 32g \
  -p 22:22 -p 30010:30010 -p 8188:8188 \
  -v /workspace/huggingface:/workspace/runpod-slim/huggingface \
  -e HF_TOKEN \
  ghcr.io/svrmsk000/sglang-minimax:comfyui-0.42 sleep infinity
```

The example volume keeps downloaded Hugging Face files outside the container. Change the host path as needed.

## ComfyUI service

Run inside the container as root: `service comfyui start`, `service comfyui status`, `service comfyui stop`, or `service comfyui restart`.

ComfyUI does not start automatically. Logs: `/tmp/comfyui.log`; PID file: `/run/comfyui.pid`. The launcher discovers NVIDIA Python-package library directories dynamically and prepends them to `LD_LIBRARY_PATH`.

## Optional model downloads

Run manually inside the container; these scripts only download weights:

```bash
/opt/comfyui-tools/download_h3_writer_models.sh
/opt/comfyui-tools/comfy-h3-video-upscaler-install.sh
```

Useful checks:

```bash
tail -f /tmp/comfyui.log
ps -fp "$(cat /run/comfyui.pid)"
/opt/comfyui-venv/bin/python -c "import torch; print(torch.__version__, torch.version.cuda, torch.cuda.is_available())"
/opt/comfyui-venv/bin/python -c "import importlib.metadata as m; print(m.version('comfyui-manager'))"
```

The final CUDA availability check requires the container to be running with GPU access (for example, `docker run --gpus all`).

## SGLang service commands

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

These profiles match `sglang/start_minimax_h3_ref2va.sh`.

## Environment

- `SGLANG_BIN`: optional path to the SGLang executable; defaults to the executable resolved during image build.
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
- `SGLANG_WARMUP_NUM_FRAMES`: default `124`.
- `PYTORCH_CUDA_ALLOC_CONF`: default `expandable_segments:True`.
- `CUDA_HOME`: default `/usr/local/cuda`.

Model weights are downloaded on first start by SGLang into `HF_HOME`; mount that directory to persist the cache.

## Notes

- The SGLang service starts only when explicitly requested; the container does not auto-start MiniMax H3 or ComfyUI.
- The ComfyUI build excludes `torch` and `torchvision` from its requirements install and verifies that its venv imports the exact same CUDA-enabled PyTorch package path as the SGLang base environment.
- The image build checks the SGLang launcher, ComfyUI launcher syntax, ComfyUI-Manager version, and shared PyTorch path. It does not perform a GPU/model-download smoke test.
- Pushes to `main` publish `latest`; pushes to `comfyui-0.42` publish `comfyui-0.42`. Both also publish a commit-SHA tag.
