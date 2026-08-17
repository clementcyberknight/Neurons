#!/usr/bin/env bash
# Download the fine-tuned Qwen2.5-1.5B IQ3_XS GGUF (~698 MB) for the ADTC 2026
# submission. Idempotent: safe to run multiple times.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_DIR="$HERE/model"
MODEL_FILE="$MODEL_DIR/qwen2.5-1.5b-custom-IQ3_XS.gguf"
MODEL_URL="https://huggingface.co/cyberknine/bau-qwen/resolve/main/qwen2.5-1.5b-custom-IQ3_XS.gguf"

mkdir -p "$MODEL_DIR"

if [[ -f "$MODEL_FILE" ]]; then
  echo "model already present at $MODEL_FILE — skipping download"
  exit 0
fi

echo "downloading $MODEL_URL -> $MODEL_FILE (~698 MB)…"
if command -v curl >/dev/null 2>&1; then
  curl -L --fail --progress-bar -o "$MODEL_FILE.partial" "$MODEL_URL"
elif command -v wget >/dev/null 2>&1; then
  wget --show-progress -O "$MODEL_FILE.partial" "$MODEL_URL"
else
  echo "neither curl nor wget available" >&2
  exit 1
fi
mv "$MODEL_FILE.partial" "$MODEL_FILE"
echo "done: $MODEL_FILE"
