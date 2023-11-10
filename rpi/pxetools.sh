#!/bin/bash

set -e

# This folder
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# Setup files supposed to be in this folder:
PXETOOLS=$SCRIPT_DIR/pxetools.py  # app to add, remove & list RPis
CONFIG=$SCRIPT_DIR/config.txt     # default RPi config to be used in boot
FSGEN=$SCRIPT_DIR/fs-gen.sh       # fs generator - main
FSSSH=$SCRIPT_DIR/fs-ssh.sh       # fs generator - SSH host keys
FSUSB=$SCRIPT_DIR/fs-usb.sh       # fs generator - USB storage for docker
PIPE=$SCRIPT_DIR/pipe.sh          # named pipe method to run commands
RPINIT=$SCRIPT_DIR/rpi-init.sh    # RPi initialization

echo "Pxettols: $PXETOOLS"
echo "Reinstalling! Check values and cancel if not ok."
read -p "Cancel? (y/n) " RESP
if [ "$RESP" = "y" ]; then exit; fi

# Install pxetools
sudo cp --remove-destination $PXETOOLS /usr/local/sbin/pxetools
sudo chmod +x /usr/local/sbin/pxetools

sudo cp --remove-destination $FSGEN /nfs/fs-gen.sh
sudo cp --remove-destination $FSSSH /nfs/fs-ssh.sh
sudo cp --remove-destination $FSSSH /nfs/fs-ssh2.sh
sudo cp --remove-destination $FSUSB /nfs/fs-ssh2.sh
sudo cp --remove-destination $RPINIT /nfs/rpi-init.sh
sudo chmod +x /nfs/fs-gen.sh
sudo chmod +x /nfs/fs-ssh.sh
sudo chmod +x /nfs/fs-ssh2.sh
sudo chmod +x /nfs/fs-usb.sh
sudo chmod +x /nfs/rpi-init.sh

# Restart
sudo systemctl restart dnsmasq rpcbind nfs-kernel-server sshd

echo "Now run sudo pxetools --add \$serial"
