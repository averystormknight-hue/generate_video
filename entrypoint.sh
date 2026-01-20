#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Download required LoRAs to container disk (no volume required)
LORA_DIR=/comfyui/models/loras
mkdir -p "$LORA_DIR"

download_if_missing() {
  local url="$1"
  local dest="$2"
  if [ -s "$dest" ]; then
    echo "Found $(basename "$dest")"
    return 0
  fi
  echo "Downloading $(basename "$dest")"
  curl -L --fail --retry 6 --retry-delay 5 --output "$dest" "$url"
}

# 4 pairs (high/low) for I2V
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/mql_casting_sex_doggy_kneel_diagonally_behind_vagina_wan22_i2v_v1_high_noise.safetensors" \
  "$LORA_DIR/mql_casting_sex_doggy_kneel_diagonally_behind_vagina_wan22_i2v_v1_high_noise.safetensors"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/mql_casting_sex_doggy_kneel_diagonally_behind_vagina_wan22_i2v_v1_low_noise.safetensors" \
  "$LORA_DIR/mql_casting_sex_doggy_kneel_diagonally_behind_vagina_wan22_i2v_v1_low_noise.safetensors"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/doggy_style_sex_front_view_Wan2.2_I2V_high_v1.0.safetensors" \
  "$LORA_DIR/doggy_style_sex_front_view_Wan2.2_I2V_high_v1.0.safetensors"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/doggy_style_sex_front_view_Wan2.2_I2V_Low_v1.0.safetensors" \
  "$LORA_DIR/doggy_style_sex_front_view_Wan2.2_I2V_Low_v1.0.safetensors"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/Pornmaster_wan%202.2_14b_I2V_Creampie_v1_high_noise.safetensors" \
  "$LORA_DIR/Pornmaster_wan%202.2_14b_I2V_Creampie_v1_high_noise.safetensors"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/Pornmaster_wan%202.2_14b_I2V_Creampie_v1_low_noise.safetensors" \
  "$LORA_DIR/Pornmaster_wan%202.2_14b_I2V_Creampie_v1_low_noise.safetensors"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/NSFW-22-H-e8.safetensors" \
  "$LORA_DIR/NSFW-22-H-e8.safetensors"
download_if_missing "https://huggingface.co/Lythiga/WAN2.2_I2V_Lora/resolve/main/NSFW-22-L-e8.safetensors" \
  "$LORA_DIR/NSFW-22-L-e8.safetensors"

# Start ComfyUI in the background
echo "Starting ComfyUI in the background..."
python /ComfyUI/main.py --listen --use-sage-attention &

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
# 이 스크립트가 컨테이너의 메인 프로세스가 됩니다.
echo "Starting the handler..."
exec python handler.py
