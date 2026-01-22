#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Error trap
trap 'echo "❌ Error on line $LINENO. Command exited with status $?"' ERR

echo "🚀 Starting entrypoint script..."

# Download required models to container disk (no volume required)
# Paths must match /ComfyUI (case-sensitive)
COMFY_ROOT=/ComfyUI
LORA_DIR=$COMFY_ROOT/models/loras
DIFFUSION_DIR=$COMFY_ROOT/models/diffusion_models
CLIP_DIR=$COMFY_ROOT/models/clip_vision
TEXT_DIR=$COMFY_ROOT/models/text_encoders
VAE_DIR=$COMFY_ROOT/models/vae

echo "📂 Creating directories..."
mkdir -p "$LORA_DIR" "$DIFFUSION_DIR" "$CLIP_DIR" "$TEXT_DIR" "$VAE_DIR"

download_if_missing() {
  local url="$1"
  local dest="$2"
  if [ -s "$dest" ]; then
    echo "✅ Found $(basename "$dest")"
    return 0
  fi
  echo "⬇️ Downloading $(basename "$dest") from $url"
  curl -L --fail --retry 6 --retry-delay 5 --output "$dest" "$url"
}

# Core Models
echo "⬇️ Checking Core Models..."
download_if_missing "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/I2V/Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors" \
  "$DIFFUSION_DIR/Wan2_2-I2V-A14B-HIGH_fp8_e4m3fn_scaled_KJ.safetensors"

download_if_missing "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/I2V/Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors" \
  "$DIFFUSION_DIR/Wan2_2-I2V-A14B-LOW_fp8_e4m3fn_scaled_KJ.safetensors"

download_if_missing "https://huggingface.co/lightx2v/Wan2.2-Lightning/resolve/main/Wan2.2-I2V-A14B-4steps-lora-rank64-Seko-V1/high_noise_model.safetensors" \
  "$LORA_DIR/high_noise_model.safetensors"

download_if_missing "https://huggingface.co/lightx2v/Wan2.2-Lightning/resolve/main/Wan2.2-I2V-A14B-4steps-lora-rank64-Seko-V1/low_noise_model.safetensors" \
  "$LORA_DIR/low_noise_model.safetensors"

download_if_missing "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors" \
  "$CLIP_DIR/clip_vision_h.safetensors"

download_if_missing "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/umt5-xxl-enc-bf16.safetensors" \
  "$TEXT_DIR/umt5-xxl-enc-bf16.safetensors"

download_if_missing "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors" \
  "$VAE_DIR/Wan2_1_VAE_bf16.safetensors"

# URL-decode the basename so %20 becomes space, etc.
url_basename() {
  python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1].split('/')[-1]))" "$1"
}

# 4 pairs (high/low) for I2V
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/mql_casting_sex_doggy_kneel_diagonally_behind_vagina_wan22_i2v_v1_high_noise.safetensors" \
  "$LORA_DIR/$(url_basename https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/mql_casting_sex_doggy_kneel_diagonally_behind_vagina_wan22_i2v_v1_high_noise.safetensors)"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/mql_casting_sex_doggy_kneel_diagonally_behind_vagina_wan22_i2v_v1_low_noise.safetensors" \
  "$LORA_DIR/$(url_basename https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/mql_casting_sex_doggy_kneel_diagonally_behind_vagina_wan22_i2v_v1_low_noise.safetensors)"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/doggy_style_sex_front_view_Wan2.2_I2V_high_v1.0.safetensors" \
  "$LORA_DIR/$(url_basename https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/doggy_style_sex_front_view_Wan2.2_I2V_high_v1.0.safetensors)"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/doggy_style_sex_front_view_Wan2.2_I2V_Low_v1.0.safetensors" \
  "$LORA_DIR/$(url_basename https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/doggy_style_sex_front_view_Wan2.2_I2V_Low_v1.0.safetensors)"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/Pornmaster_wan%202.2_14b_I2V_Creampie_v1_high_noise.safetensors" \
  "$LORA_DIR/$(url_basename https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/Pornmaster_wan%202.2_14b_I2V_Creampie_v1_high_noise.safetensors)"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/Pornmaster_wan%202.2_14b_I2V_Creampie_v1_low_noise.safetensors" \
  "$LORA_DIR/$(url_basename https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/Pornmaster_wan%202.2_14b_I2V_Creampie_v1_low_noise.safetensors)"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/NSFW-22-H-e8.safetensors" \
  "$LORA_DIR/$(url_basename https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/NSFW-22-H-e8.safetensors)"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/NSFW-22-L-e8.safetensors" \
  "$LORA_DIR/$(url_basename https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/NSFW-22-L-e8.safetensors)"

# Start ComfyUI in the background
echo "Starting ComfyUI in the background..."
python3 /ComfyUI/main.py --listen --use-sage-attention &

# Wait for ComfyUI to be ready
echo "Waiting for ComfyUI to be ready..."
max_wait=120  # 최대 2분 대기
wait_count=0
while [ $wait_count -lt $max_wait ]; do
    if curl -s http://127.0.0.1:8188/ > /dev/null 2>&1; then
        echo "ComfyUI is ready!"
        break
    fi
    echo "Waiting for ComfyUI... ($wait_count/$max_wait)"
    sleep 2
    wait_count=$((wait_count + 2))
done

if [ $wait_count -ge $max_wait ]; then
    echo "Error: ComfyUI failed to start within $max_wait seconds"
    exit 1
fi

# Start the handler in the foreground
echo "🐍 Checking Python environment..."
python3 --version
python3 -c "import runpod; print('RunPod installed')" || echo "❌ RunPod NOT installed"
python3 -c "import websocket; print('Websocket installed')" || echo "❌ Websocket NOT installed"

echo "🏁 Starting the handler..."
python3 handler.py
HANDLER_EXIT=$?
echo "❌ Handler exited with code $HANDLER_EXIT"
exit $HANDLER_EXIT
