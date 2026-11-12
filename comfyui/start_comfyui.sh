#!/usr/bin/env bash
set -euo pipefail

cd /opt/ComfyUI
export PATH="/opt/comfyui-venv/bin:$PATH"

nohup python3 main.py \
  --listen 0.0.0.0 \
  --port 8188 \
  --enable-cors-header \
  --preview-method none \
  --high-ram \
  --enable-manager \
  > /tmp/comfyui.log 2>&1 </dev/null &

echo "$!" > /run/comfyui.pid
echo "ComfyUI started (PID $(cat /run/comfyui.pid)); log: /tmp/comfyui.log"
