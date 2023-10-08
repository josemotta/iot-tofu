#!/bin/bash

# iot-tofu notes:
#   - Based on link below but the network is supposed to be already set.
#     https://www.raspberrypi.com/documentation/computers/remote-access.html#using-pxetools
#
#   - The main network has a 'region' based on a local LAN that includes the Tofu & RPis.
#   - Tofu is the boot server for dozens RPis.
#		- Each region LAN connects to the main network & then to the Internet.
# 	- Region
#       router: dedicated LAN for Tofu & RPis (192.168.10.1)
# 	    dns: nameserver 127.0.0.1 to force using dnsmasq dns
# 	- Main
#       router: connected to Internet (gateway 192.168.1.254)
# 	    dns: 192.168.1.254 to be set at dnsmasq server
#   - Firewall is not needed yet, then original 'iptables' commands are commented here.

set -e

# RPI TOFU setup
#		- initial setup is commented out below.
#   - since this script works together with reset_pxetools.sh
#		- before the very first run, please uncomment install below
#
# sudo apt update
# sudo apt full-upgrade
# sudo apt install -y \
# 	python3 \
# 	python3-pip \
# 	ipcalc \
# 	nfs-kernel-server \
# 	dnsmasq \
# 	iptables-persistent \
# 	xz-utils \
# 	nmap \
# 	kpartx \
# 	rsync
# sudo pip3 install tabulate
# curl -fsSL https://get.docker.com -o get-docker.sh
# sudo sh get-docker.sh
# sudo groupadd docker
# sudo usermod -aG docker $USER
# Note: Reboot for user membership evaluation

# Get network info. It should be already set!
NAMESERVER=$(cat /etc/resolv.conf | grep nameserver | head -n 1 | cut -d " " -f2)
GATEWAY=$(ip -4 route | grep default | head -n 1 | cut -d " " -f3)
IP=$(ifconfig eth0 | grep "inet " | cut -d " " -f10)
NETMASK=$(ifconfig eth0 | grep "inet " | cut -d " " -f13)
DNSSERVER=192.168.1.254
DHCPRANGE=192.168.10.50,192.168.10.99,255.255.255.0,12h
# BRD=$(ifconfig eth0 | grep "inet " | cut -d " " -f16)

# Raspberry Pi OS bases to be downloaded
RPI_LITE_ARMHF='https://downloads.raspberrypi.org/raspios_lite_armhf/root.tar.xz'
RPI_LITE_ARM64='https://downloads.raspberrypi.org/raspios_lite_arm64/root.tar.xz'

# The pxetools code & config.txt are supposed to be in this folder
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)
PXETOOLS=$SCRIPT_DIR/pxetools.py
CONFIG=$SCRIPT_DIR/config.txt
FSGEN=$SCRIPT_DIR/fsgen.sh

#   - The 'interfaces' (or equivalent) should be already set:
#     cat << EOF | sudo tee /etc/network/interfaces.d/interfaces
#     auto lo
#     iface lo inet loopback
#
#     auto eth0
#     iface eth0 inet static
#       address $IP
#       netmask $NETMASK
#       gateway $GATEWAY
#     EOF

echo "IP: $IP"
echo "Netmask: $NETMASK"
echo "Nameserver: $NAMESERVER"
echo "Gateway: $GATEWAY"
echo "DNS: $DNSSERVER"
echo "DHCP range: $DHCPRANGE"
echo "Pxettols: $PXETOOLS"
# echo "Broadcast: $BRD"

# IP: 192.168.10.10
# Netmask: 255.255.255.0
# Nameserver: 127.0.0.1
# Gateway: 192.168.10.1
# DNS: 192.168.1.254
# DHCP range: 192.168.10.101,192.168.10.199,255.255.255.0,12h
# Pxettols: /home/jo/rpi/iot-tofu/rpi/pxetools.py

echo "Installing! Check values and cancel if not ok."

#	Network is not supposed to be changed down here
read -p "Cancel? (y/n) " RESP
if [ "$RESP" = "y" ]; then exit; fi

sudo mkdir -p /nfs
sudo mkdir -p /tftpboot
sudo cp -r /boot /tftpboot/base
sudo chmod -R 777 /tftpboot

# Use "config.txt" extracted from this folder
sudo cp --remove-destination $CONFIG /tftpboot/base/config.txt
sudo cp --remove-destination $FSGEN /nfs/fsgen.sh
sudo chmod +x /nfs/fsgen.sh

echo "Writing dnsmasq.conf"
cat << EOF | sudo tee /etc/dnsmasq.d/dnsmasq.conf
interface=eth0
no-resolv
server=$DNSSERVER
dhcp-range=$DHCPRANGE
bind-interfaces
log-dhcp
log-queries
enable-tftp
tftp-root=/tftpboot
tftp-no-fail
pxe-service=0,"Raspberry Pi Boot"
dhcp-boot=pxelinux.0
EOF

# Get Raspberry Pi OS lite images
echo "Getting RPi OS lite images to use as NFS root"
# lite_armhf
sudo mkdir -p /nfs/bases/lite_armhf
cd /nfs/bases/lite_armhf
sudo wget -O rpi_lite_armhf.xz $RPI_LITE_ARMHF
sudo tar -xf rpi_lite_armhf.xz
sudo rm rpi_lite_armhf.xz
# lite_arm64
sudo mkdir -p /nfs/bases/lite_arm64
cd /nfs/bases/lite_arm64
sudo wget -O rpi_lite_arm64.xz $RPI_LITE_ARM64
sudo tar -xf rpi_lite_arm64.xz
sudo rm rpi_lite_arm64.xz

# Install pxetools
sudo cp $PXETOOLS /usr/local/sbin/pxetools
sudo chmod +x /usr/local/sbin/pxetools

# # Flush any rules that might exist
# sudo iptables -t raw --flush

# # Create the DHCP_clients chain in the 'raw' table
# sudo iptables -t raw -N DHCP_clients || true

# # Incoming DHCP, pass to chain processing DHCP
# sudo iptables -t raw -A PREROUTING -p udp --dport 67 -j DHCP_clients

# # Deny clients not in chain not listed above
# sudo iptables -t raw -A DHCP_clients -j DROP

# sudo iptables-save | sudo tee /etc/iptables/rules.v4

# Disable DHCP client
sudo systemctl stop dhcpcd
sudo systemctl disable dhcpcd
sudo systemctl restart networking

# Start services
sudo systemctl enable dnsmasq rpcbind nfs-kernel-server
sudo systemctl restart dnsmasq rpcbind nfs-kernel-server

echo "Now run sudo pxetools --add \$serial"
