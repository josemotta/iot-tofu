#!/bin/bash

set -e

# The pxetools code is supposed to be in this same folder
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
PXETOOLS=$SCRIPT_DIR/pxetools.py

echo "Pxettols: $PXETOOLS"
echo "Reinstalling! Check values and cancel if not ok."
read -p "Cancel? (y/n) " RESP
if [ "$RESP" = "y" ]; then exit; fi

# Add pxetools code to Tofu
sudo rm /usr/local/sbin/pxetools
sudo cp $PXETOOLS /usr/local/sbin/pxetools
sudo chmod +x /usr/local/sbin/pxetools

# Disable DHCP client
# sudo systemctl stop dhcpcd
# sudo systemctl disable dhcpcd
# sudo systemctl restart networking

# Restart services
# sudo systemctl enable dnsmasq rpcbind nfs-kernel-server
sudo systemctl restart dnsmasq rpcbind nfs-kernel-server

echo "Now run sudo pxetools --add \$serial"