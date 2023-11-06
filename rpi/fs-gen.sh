#!/bin/bash
# Adapted from https://www.raspberrypi.com/documentation/computers/remote-access.html#network-boot-your-raspberry-pi

# This folder:
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

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

while [ -f $CLIENT_FS/boot/owner ]
do
  sleep .1
done

OWNER=$(<$CLIENT_FS/boot/owner)
RPI_USR_HOME=$CLIENT_FS/home/$OWNER

# Generate a copy from base fs to $CLIENT_FS
sudo mkdir -p $CLIENT_FS
sudo rsync -xa $BASE_FS/ $CLIENT_FS/

# install scripts for ssh & rpi initializaton
sudo cp /nfs/fs-ssh.sh $CLIENT_FS/
sudo cp /nfs/rpi-init.sh $RPI_USR_HOME
sudo chown $OWNER:$OWNER $RPI_USR_HOME/rpi-init.sh
sudo chmod +x $RPI_USR_HOME/rpi-init.sh

# Regenerate SSH host keys on CLIENT_FS
cd $CLIENT_FS
sudo mount --bind /dev dev
sudo mount --bind /sys sys
sudo mount --bind /proc proc
sudo chroot . ./fs-ssh.sh
sudo umount dev sys proc

echo Generated fs for $CLIENT_FS
