FROM lmsysorg/sglang:latest

ARG COMFYUI_REF=v0.42.1
ARG COMFYUI_COMMIT=63be2f9b82ad0dac88a7ceaa28a9cf3154125a18
ARG COMFYUI_MANAGER_REF=4.2.2
ARG COMFYUI_MANAGER_COMMIT=bd4ede2237c97b3a71569a0301a0be9db226c7e9

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        init-system-helpers \
        openssh-server \
        rsync \
        jq \
        nano \
        git \
        python3-venv \
    && mkdir -p /root/.ssh /run/sshd /etc/ssh/sshd_config.d \
    && chmod 700 /root/.ssh \
    && printf '%s\\n' \
        'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSG3vISjWzjlxZDV8w1FbNDa2aEty4hx0b+wq42Viu7 root@DESKTOP-6S75UR7' \
        > /root/.ssh/authorized_keys \
    && chmod 600 /root/.ssh/authorized_keys \
    && printf '%s\\n' \
        'Port 22' \
        'PermitRootLogin prohibit-password' \
        'PubkeyAuthentication yes' \
        'PasswordAuthentication no' \
        'KbdInteractiveAuthentication no' \
        > /etc/ssh/sshd_config.d/00-container.conf \
    && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh

COPY sglang/ /opt/sglang-minimax/
COPY comfyui/ /opt/comfyui-tools/

RUN set -eux; \
    SGLANG_PATH="$(command -v sglang)"; \
    test -x "$SGLANG_PATH"; \
    printf '%s\\n' "$SGLANG_PATH" > /etc/sglang-bin; \
    chmod 0644 /etc/sglang-bin; \
    command -v service; \
    command -v sshd; \
    command -v rsync; \
    command -v jq; \
    command -v nano; \
    mkdir -p /etc/init.d; \
    chmod 0755 /opt/sglang-minimax/sgmax /opt/sglang-minimax/start_minimax_h3_ref2va.sh; \
    ln -sfn /opt/sglang-minimax/sgmax /etc/init.d/sgmax; \
    bash -n /opt/sglang-minimax/sgmax; \
    bash -n /opt/sglang-minimax/start_minimax_h3_ref2va.sh; \
    bash -n /usr/local/bin/docker-entrypoint.sh; \
    bash -n /opt/comfyui-tools/start_comfyui.sh; \
    SGLANG_PYTHON="$(head -n 1 "$SGLANG_PATH" | sed 's/^#!//')"; \
    if [ ! -x "$SGLANG_PYTHON" ]; then SGLANG_PYTHON="$(command -v python3)"; fi; \
    "$SGLANG_PYTHON" -c 'import torch, torchvision; assert torch.version.cuda, "Base SGLang PyTorch is not CUDA-enabled"; print("Base PyTorch:", torch.__version__, "CUDA:", torch.version.cuda, "torch:", torch.__file__)'; \
    BASE_TORCH_SITE="$("$SGLANG_PYTHON" -c 'import pathlib, torch; print(pathlib.Path(torch.__file__).resolve().parent.parent)')"; \
    "$SGLANG_PYTHON" -m venv --system-site-packages /opt/comfyui-venv; \
    COMFY_SITE="$("/opt/comfyui-venv/bin/python" -c 'import sysconfig; print(sysconfig.get_paths()["purelib"])')"; \
    printf '%s\\n' "$BASE_TORCH_SITE" > "$COMFY_SITE/sglang-base-site-packages.pth"; \
    /opt/comfyui-venv/bin/python -m pip install --no-cache-dir --upgrade pip; \
    git clone --depth 1 --branch "$COMFYUI_REF" https://github.com/Comfy-Org/ComfyUI.git /opt/ComfyUI; \
    test "$(git -C /opt/ComfyUI rev-parse HEAD)" = "$COMFYUI_COMMIT"; \
    git clone --depth 1 --branch "$COMFYUI_MANAGER_REF" https://github.com/Comfy-Org/ComfyUI-Manager.git /opt/ComfyUI/custom_nodes/ComfyUI-Manager; \
    test "$(git -C /opt/ComfyUI/custom_nodes/ComfyUI-Manager rev-parse HEAD)" = "$COMFYUI_MANAGER_COMMIT"; \
    grep -Ev '^[[:space:]]*(torch|torchvision)([[:space:]<=>!~;#]|$)' /opt/ComfyUI/requirements.txt > /tmp/comfyui-requirements.txt; \
    /opt/comfyui-venv/bin/python -m pip install --no-cache-dir -r /tmp/comfyui-requirements.txt; \
    /opt/comfyui-venv/bin/python -m pip install --no-cache-dir -r /opt/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt; \
    /opt/comfyui-venv/bin/python -m pip install --no-cache-dir --no-deps --editable /opt/ComfyUI/custom_nodes/ComfyUI-Manager; \
    /opt/comfyui-venv/bin/python -c 'import importlib.metadata as m, pathlib, torch, torchvision; assert m.version("comfyui-manager") == "4.2.2", m.version("comfyui-manager"); assert torch.version.cuda, "CUDA-enabled PyTorch missing in ComfyUI venv"; print("ComfyUI Manager:", m.version("comfyui-manager")); print("ComfyUI venv PyTorch:", torch.__version__, "CUDA:", torch.version.cuda, "torch:", torch.__file__)'; \
    VENV_TORCH_SITE="$("/opt/comfyui-venv/bin/python" -c 'import pathlib, torch; print(pathlib.Path(torch.__file__).resolve().parent.parent)')"; \
    test "$VENV_TORCH_SITE" = "$BASE_TORCH_SITE"; \
    chmod 0755 /opt/comfyui-tools/start_comfyui.sh

EXPOSE 22 30010 8188

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
