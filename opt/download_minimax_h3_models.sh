#!/usr/bin/env bash
set -euo pipefail

MODELS="/opt/ComfyUI/models"

download() {
  local url="$1"
  local destination="$2"
  local checksum="$3"
  local partial="${destination}.part"
  local directory
  directory="$(dirname "$destination")"
  mkdir -p "$directory"

  if [[ -f "$destination" ]]; then
    if echo "$checksum  $destination" | sha256sum --check --status; then
      echo "Already downloaded: $destination"
      return
    fi
    echo "ERROR: Existing file has an invalid SHA256: $destination" >&2
    exit 1
  fi

  echo "Downloading: $(basename "$destination")"
  local -a auth=()
  if [[ -n "${HF_TOKEN:-}" ]]; then
    auth=(-H "Authorization: Bearer $HF_TOKEN")
  fi

  curl --fail --location --show-error \
    --retry 5 --retry-all-errors --retry-delay 5 \
    --connect-timeout 30 --continue-at - \
    "${auth[@]}" "$url" --output "$partial"

  echo "$checksum  $partial" | sha256sum --check --status || {
    echo "ERROR: SHA256 verification failed: $destination" >&2
    exit 1
  }
  mv "$partial" "$destination"
  echo "Saved: $destination"
}

download \
  "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/eb8a16107c595128b3a578f82d2ce2f75920c355/diffusion_models/minimax_h3_fl2va_pruned_int8_convrot.safetensors" \
  "$MODELS/diffusion_models/h3/minimax_h3_fl2va_pruned_int8_convrot.safetensors" \
  "e889202c41dafb67b10d67b97f0d8541508036a6090af23425a5c2615d03c47a"

download \
  "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/3f57e8291d2ef846f9a074b1b76d2767db434abe/diffusion_models/minimax_h3_ref2va_bf16.safetensors" \
  "$MODELS/diffusion_models/h3/minimax_h3_ref2va_bf16.safetensors" \
  "e32c54c1a7b4f5f397f195cea267ccb18806303bb665678c4bee60953bdf3026"

download \
  "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/3f57e8291d2ef846f9a074b1b76d2767db434abe/text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors" \
  "$MODELS/text_encoders/qwen3vl_32b_minimax_h3_int8_convrot.safetensors" \
  "bc2ced0fbea64757fa9acddccfc0b3f4819d1dcf1da6c124d690d368be283923"

download \
  "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/eb8a16107c595128b3a578f82d2ce2f75920c355/vae/minimax_h3_audio_vae_fp32.safetensors" \
  "$MODELS/vae/minimax_h3_audio_vae_fp32.safetensors" \
  "8e505d95dd1561d47abd43d4238fd40d9bb1ae9e147ed0a4cba778d76ae4db48"

download \
  "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/eb8a16107c595128b3a578f82d2ce2f75920c355/vae/minimax_h3_video_vae_fp16.safetensors" \
  "$MODELS/vae/minimax_h3_video_vae_fp16.safetensors" \
  "7c1f131492e7eddacaac9069a61b81bdd39de5cc96561e677c5eab1cdce5e522"

download \
  "https://huggingface.co/Comfy-Org/MiniMax-H3/resolve/0fea91688aefb62d4eb94d5952f277f46c298284/loras/minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors" \
  "$MODELS/loras/minimax_h3_ref2v_turbo_4step_v0.1_comfyui_bf16.safetensors" \
  "5b9ab5ade15d0775676d01a907268a69a1468dc6033b3b0d3ded5502f3ebb84c"

echo "All six MiniMax H3 core models are downloaded and verified."
