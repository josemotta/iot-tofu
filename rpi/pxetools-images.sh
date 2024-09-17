#!/bin/bash

# # Raspberry Pi OS bases to be downloaded:
# RPI_LITE_ARMHF='https://downloads.raspberrypi.org/raspios_lite_armhf/root.tar.xz'
# RPI_LITE_ARM64='https://downloads.raspberrypi.org/raspios_lite_arm64/root.tar.xz'
# RPI_ARMHF='https://downloads.raspberrypi.org/raspios_armhf/root.tar.xz'
# RPI_ARM64='https://downloads.raspberrypi.org/raspios_arm64/root.tar.xz'
# RPI_12_BOOKWORM_LITE_ARM64='https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz'

RPI_11_BULLSEYE_LITE_ARM64='https://downloads.raspberrypi.com/raspios_lite_arm64/root.tar.xz'

# Please note this code is good for RPi OS 11 (bullseye). For version 12 (bookworm) changes are needed:
#
# - [config.txt](https://www.raspberrypi.com/documentation/computers/config_txt.html#what-is-config-txt)
#   Instead of the BIOS found on a conventional PC, Raspberry Pi devices use a configuration file
#   called config.txt. The GPU reads config.txt before the Arm CPU and Linux initialise.
#   Raspberry Pi OS 12 bookworm looks for this file in the boot partition, located at /boot/firmware/.
#   Prior to Raspberry Pi OS 12 Bookworm, Raspberry Pi OS stored the boot partition at /boot/.
#   Current code stores config.txt at /boot/.

# Get Raspberry Pi OS lite images

echo ""
echo "Get RPi OS images"

# rpi_11_bullseye_lite_arm64
if [ ! -d /nfs/bases/rpi_11_bullseye_lite_arm64 ]; then
sudo mkdir -p /nfs/bases/rpi_11_bullseye_lite_arm64
cd /nfs/bases/rpi_11_bullseye_lite_arm64
sudo wget -O rpi_11_bullseye_lite_arm64 $RPI_11_BULLSEYE_LITE_ARM64
sudo tar -xf rpi_11_bullseye_lite_arm64
sudo rm rpi_11_bullseye_lite_arm64
fi

# rpi_12_bookworm_lite_arm64
#if [ ! -d /nfs/bases/rpi_12_bookworm_lite_arm64 ]; then
#sudo mkdir -p /nfs/bases/rpi_12_bookworm_lite_arm64
#cd /nfs/bases/rpi_12_bookworm_lite_arm64
#sudo wget -O rpi_12_bookworm_lite_arm64 $RPI_12_BOOKWORM_LITE_ARM64
#sudo tar -xf rpi_12_bookworm_lite_arm64
#sudo rm rpi_12_bookworm_lite_arm64
#fi

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
