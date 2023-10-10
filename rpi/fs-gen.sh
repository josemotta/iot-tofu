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

# Generate a copy from base fs to $CLIENT_FS
sudo mkdir -p $CLIENT_FS
sudo cp -r $BASE_FS/* $CLIENT_FS/
sudo cp /nfs/fs-ssh.sh $CLIENT_FS/

#sudo apt install rsync
#sudo rsync -xa --progress $BASE_FS $CLIENT_FS

# Regenerate SSH host keys on CLIENT_FS
cd $CLIENT_FS
sudo mount --bind /dev dev
sudo mount --bind /sys sys
sudo mount --bind /proc proc
sudo chroot . ./fs-ssh.sh
sudo umount dev sys proc

echo Generated fs for $CLIENT_FS
