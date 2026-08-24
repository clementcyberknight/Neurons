#!/usr/bin/env bash
# Download the fine-tuned bau-small-1.5b Q4_K_M GGUF (~941 MB) for the ADTC 2026
# submission. Idempotent: safe to run multiple times.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODEL_DIR="$HERE/model"
MODEL_FILE="$MODEL_DIR/bau-small-1.5b.gguf"
MODEL_URL="https://huggingface.co/cyberknine/bau-small-1.5b-GGUF/resolve/main/bau-small-1.5b.gguf"

mkdir -p "$MODEL_DIR"

if [[ -f "$MODEL_FILE" ]]; then
  echo "model already present at $MODEL_FILE — skipping download"
  exit 0
fi

echo "downloading $MODEL_URL -> $MODEL_FILE (~941 MB)…"
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
