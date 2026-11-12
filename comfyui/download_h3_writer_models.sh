#!/usr/bin/env bash
set -euo pipefail
COMFY="${COMFY:-/opt/ComfyUI}"
DEST="$COMFY/models/LLM/gemma-4-26b"
mkdir -p "$DEST"
wget -c \
  "https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF/resolve/main/gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf" \
  -O "$DEST/gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf"
wget -c \
  "https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF/resolve/main/mmproj-BF16.gguf" \
  -O "$DEST/mmproj-BF16.gguf"
echo "Prompt Writer GGUF files downloaded to $DEST"
echo "Turbo LoRA is downloaded by the common MiniMax H3 model downloader."
