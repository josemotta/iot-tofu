#!/bin/bash

# # Raspberry Pi OS bases to be downloaded:
# RPI_LITE_ARMHF='https://downloads.raspberrypi.org/raspios_lite_armhf/root.tar.xz'
# RPI_LITE_ARM64='https://downloads.raspberrypi.org/raspios_lite_arm64/root.tar.xz'
# RPI_ARMHF='https://downloads.raspberrypi.org/raspios_armhf/root.tar.xz'
# RPI_ARM64='https://downloads.raspberrypi.org/raspios_arm64/root.tar.xz'

# Raspberry Pi OS bases to be downloaded:
RPI_12_BOOKWORM_LITE_ARM64='https://downloads.raspberrypi.com/raspios_lite_arm64/root.tar.xz'

# Get Raspberry Pi OS lite images

echo ""
echo "Get RPi OS images"

# rpi_12_bookworm_lite_arm64
if [ ! -d /nfs/bases/rpi_12_bookworm_lite_arm64 ]; then
sudo mkdir -p /nfs/bases/rpi_12_bookworm_lite_arm64
cd /nfs/bases/rpi_12_bookworm_lite_arm64
sudo wget -O rpi_12_bookworm_lite_arm64 $RPI_12_BOOKWORM_LITE_ARM64
sudo tar -xf rpi_12_bookworm_lite_arm64
sudo rm rpi_12_bookworm_lite_arm64
fi

# # lite_armhf
# if [ ! -d /nfs/bases/lite_armhf ]; then
# sudo mkdir -p /nfs/bases/lite_armhf
# cd /nfs/bases/lite_armhf
# sudo wget -O rpi_lite_armhf.xz $RPI_LITE_ARMHF
# sudo tar -xf rpi_lite_armhf.xz
# sudo rm rpi_lite_armhf.xz
# fi

# # armhf
# if [ ! -d /nfs/bases/armhf ]; then
# sudo mkdir -p /nfs/bases/armhf
# cd /nfs/bases/armhf
# sudo wget -O rpi_armhf.xz $RPI_ARMHF
# sudo tar -xf rpi_armhf.xz
# sudo rm rpi_armhf.xz
# fi

# # arm64
# if [ ! -d /nfs/bases/arm64 ]; then
# sudo mkdir -p /nfs/bases/arm64
# cd /nfs/bases/arm64
# sudo wget -O rpi_arm64.xz $RPI_ARM64
# sudo tar -xf rpi_arm64.xz
# sudo rm rpi_arm64.xz
# fi
