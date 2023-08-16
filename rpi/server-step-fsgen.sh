#!/bin/bash
# https://www.raspberrypi.com/documentation/computers/remote-access.html#network-boot-your-raspberry-pi

if [ $1 == "" ]; then
  echo Missing client id
  exit 1
fi
export CLIENT_ID=$1

# Generate a copy from current fs to $CLIENT_ID
sudo mkdir -p /nfs/$CLIENT_ID
sudo apt install rsync
sudo rsync -xa --progress --exclude /nfs / /nfs/$CLIENT_ID

# Regenerate SSH host keys on the CLIENT_ID filesystem
# by chrooting into it
cd /nfs/$CLIENT_ID
sudo mount --bind /dev dev
sudo mount --bind /sys sys
sudo mount --bind /proc proc
sudo chroot .
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server
exit
sudo umount dev sys proc

echo Generated fs for $CLIENT_ID
