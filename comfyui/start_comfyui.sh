#!/usr/bin/env bash
set -euo pipefail
cd /opt/ComfyUI
NVIDIA_LIB_DIRS="$(
  /opt/comfyui-venv/bin/python - <<'PY'
import importlib.util
from pathlib import Path
spec = importlib.util.find_spec("nvidia")
paths = set()
if spec and spec.submodule_search_locations:
    for location in spec.submodule_search_locations:
        paths.update(str(p.resolve()) for p in Path(location).glob("*/lib") if p.is_dir())
print(":".join(sorted(paths)))
PY
)"
if [[ -z "$NVIDIA_LIB_DIRS" ]]; then
  echo "WARNING: No NVIDIA Python-package library directories discovered." >&2
fi
export LD_LIBRARY_PATH="${NVIDIA_LIB_DIRS:+${NVIDIA_LIB_DIRS}:}${LD_LIBRARY_PATH:-}"
export PATH="/opt/comfyui-venv/bin:$PATH"
exec /opt/comfyui-venv/bin/python main.py --listen 0.0.0.0 --port 8188 --enable-cors-header --preview-method none --high-ram --enable-manager
