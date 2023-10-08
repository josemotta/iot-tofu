#!/bin/bash
# Adapted from https://www.raspberrypi.com/documentation/computers/remote-access.html#network-boot-your-raspberry-pi

if [ $1 == "" ]; then
  echo Missing base fs
  exit 1
fi
export BASE_FS=$1

if [ $2 == "" ]; then
  echo Missing client fs
  exit 1
fi
export CLIENT_FS=$2

# Generate a copy from current fs to $CLIENT_ID
sudo mkdir -p $CLIENT_FS
sudo apt install rsync
sudo rsync -xa --progress $BASE_FS $CLIENT_FS

# Regenerate SSH host keys on the CLIENT_ID filesystem
# by chrooting into it
cd $CLIENT_FS
sudo { mount --bind /dev dev ; mount --bind /sys sys ; mount --bind /proc proc }
sudo { chroot . ; rm /etc/ssh/ssh_host_* ; dpkg-reconfigure openssh-server } &
sudo umount dev sys proc

echo Generated fs for $CLIENT_FS
