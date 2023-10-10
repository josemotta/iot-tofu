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

set -e

sudo apt update
sudo apt full-upgrade
sudo apt install -y \
	python3 \
	python3-pip \
	ipcalc \
	nfs-kernel-server \
	dnsmasq \
	iptables-persistent \
	xz-utils \
	nmap \
	kpartx \
	rsync
sudo pip3 install tabulate

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER

# The 'interfaces' is supposed to be already set:
# cat << EOF | sudo tee /etc/network/interfaces.d/interfaces
# auto lo
# iface lo inet loopback
# auto eth0
# iface eth0 inet static
#   address $IP
#   netmask $NETMASK
#   gateway $GATEWAY
# EOF

# Get network info:
NAMESERVER=$(cat /etc/resolv.conf | grep nameserver | head -n 1 | cut -d " " -f2)
GATEWAY=$(ip -4 route | grep default | head -n 1 | cut -d " " -f3)
IP=$(ifconfig eth0 | grep "inet " | cut -d " " -f10)
NETMASK=$(ifconfig eth0 | grep "inet " | cut -d " " -f13)
DNSSERVER=192.168.1.254
DHCPRANGE=192.168.10.50,192.168.10.99,255.255.255.0,12h
# BRD=$(ifconfig eth0 | grep "inet " | cut -d " " -f16)

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

echo "These values will be used in setup."
