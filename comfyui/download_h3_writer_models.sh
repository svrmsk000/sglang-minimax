#!/usr/bin/env bash
set -euo pipefail
COMFY="${COMFY:-/opt/ComfyUI}"
DEST="$COMFY/models/LLM/gemma-4-26b"
mkdir -p "$DEST" "$COMFY/models/loras"

wget -c \
  "https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF/resolve/main/gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf" \
  -O "$DEST/gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf"

wget -c \
  "https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF/resolve/main/mmproj-BF16.gguf" \
  -O "$DEST/mmproj-BF16.gguf"

wget -c \
  "https://huggingface.co/lightx2v/Minimax-h3-Turbo/resolve/main/minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors" \
  -O "$COMFY/models/loras/minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors"

echo "Prompt Writer GGUF files and MiniMax H3 Turbo LoRA downloaded."
