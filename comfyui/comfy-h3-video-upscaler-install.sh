#!/usr/bin/env bash
set -euo pipefail
COMFY="${COMFY:-/opt/ComfyUI}"
mkdir -p "$COMFY/models/latent_upscale_models" "$COMFY/models/loras"
wget -c \
  "https://huggingface.co/LBH-123-AI/Minimax_h3_latent_Upscaler/resolve/main/minimax_h3_latent_upscaler_3d_conv_v1/minimax_h3_latent_upscaler_3d_conv_v1_bf16.safetensors" \
  -O "$COMFY/models/latent_upscale_models/minimax_h3_latent_upscaler_3d_conv_v1_bf16.safetensors"
wget -c \
  "https://huggingface.co/sandpies/ComfyUI-H3-Video-Upsampler/resolve/main/lora/open_h3_regenerate_2k_r256pp_bf16.safetensors" \
  -O "$COMFY/models/loras/open_h3_regenerate_2k_r256pp_bf16.safetensors"
echo "H3 Video Upsampler models downloaded."
