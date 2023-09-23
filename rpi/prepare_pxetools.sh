#!/bin/bash

# Based on link below but the network is supposed to be already set.
# https://www.raspberrypi.com/documentation/computers/remote-access.html#using-pxetools

set -e

# RPI TOFU setup
#		- commented for development
#		- just run once!
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

# Get network info. It should be already set!
NAMESERVER=$(cat /etc/resolv.conf | grep nameserver | head -n 1 | cut -d " " -f2)
GATEWAY=$(ip -4 route | grep default | head -n 1 | cut -d " " -f3)
IP=$(ifconfig eth0 | grep "inet " | cut -d " " -f10)
NETMASK=$(ifconfig eth0 | grep "inet " | cut -d " " -f13)
DNSSERVER=192.168.1.254
DHCPRANGE=192.168.10.101,192.168.10.199,255.255.255.0,12h
# BRD=$(ifconfig eth0 | grep "inet " | cut -d " " -f16)

RPI_LITE_ARMHF='https://downloads.raspberrypi.org/raspios_lite_armhf/root.tar.xz'
RPI_LITE_ARM64='https://downloads.raspberrypi.org/raspios_lite_arm64/root.tar.xz'

# RPI Tofu network
#		There is a 'region' with local LAN including the Tofu & RPis.
#		The local LAN connects to the main network, with Internet access.
# 	- region router: dedicated LAN for Tofu & RPis (192.168.10.1)
# 	- region dns: nameserver 127.0.0.1 to force dnsmasq dns
# 	- main router: connected to Internet (192.168.1.254)
# 	- main dns: 192.168.1.254 to be set at dnsmasq server
#
# IP: 192.168.10.10
# Netmask: 255.255.255.0
# Nameserver: 127.0.0.1
# Gateway: 192.168.10.1
# DNS: 192.168.1.254
# DHCP range: 192.168.10.101,192.168.10.199,255.255.255.0,12h
# Broadcast: 192.168.10.255

echo "IP: $IP"
echo "Netmask: $NETMASK"
echo "Nameserver: $NAMESERVER"
echo "Gateway: $GATEWAY"
echo "DNS: $DNSSERVER"
echo "DHCP range: $DHCPRANGE"
# echo "Broadcast: $BRD"

exit
# TODO:
#		- check network values and exit if they are not ok
#		- do not change network here

# The 'interfaces' should be already set.

# cat << EOF | sudo tee /etc/network/interfaces.d/interfaces
# auto lo
# iface lo inet loopback

# auto eth0
# iface eth0 inet static
# 	address $IP
# 	netmask $NETMASK
# 	gateway $GATEWAY
# EOF

sudo mkdir -p /nfs
sudo mkdir -p /tftpboot
sudo cp -r /boot /tftpboot/base
sudo cp /boot/bootcode.bin /tftpboot
sudo chmod -R 777 /tftpboot

echo "Writing dnsmasq.conf"
cat << EOF | sudo tee /etc/dnsmasq.d/dnsmasq.conf
interface=eth0
server=$DNSSERVER
dhcp-range=$DHCPRANGE
bind-interfaces
log-dhcp
log-queries
enable-tftp
tftp-root=/tftpboot
tftp-no-fail
pxe-service=0, "Raspberry Pi Boot", bootcode.bin
EOF

# Get Raspberry Pi OS lite images
echo "Getting RPi OS lite images to use as NFS root"
# lite_armhf
sudo mkdir -p /nfs/bases/lite_armhf
cd /nfs/bases/lite_armhf
sudo wget -O raspios.img.xz $RPI_LITE_ARMHF
sudo tar -xf raspios.img.xz
sudo rm raspios.img.xz
# lite_arm64
sudo mkdir -p /nfs/bases/lite_arm64
cd /nfs/bases/lite_arm64
sudo wget -O raspios.img.xz $RPI_LITE_ARM64
sudo tar -xf raspios.img.xz
sudo rm raspios.img.xz

cd /nfs
sudo wget  -O /usr/local/sbin/pxetools https://datasheets.raspberrypi.org/soft/pxetools.py
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
sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq
sudo systemctl enable rpcbind
sudo systemctl restart rpcbind
sudo systemctl enable nfs-kernel-server
sudo systemctl restart nfs-kernel-server

echo "Now run sudo pxetools --add \$serial"
