#!/bin/bash

# https://www.raspberrypi.com/documentation/computers/remote-access.html#using-pxetools

# Get network info
NAMESERVER=$(cat /etc/resolv.conf | grep nameserver | head -n 1 | cut -d " " -f2)
GATEWAY=$(ip -4 route | grep default | head -n 1 | cut -d " " -f3)
IP=$(ifconfig eth0 | grep "inet " | cut -d " " -f10)
NETMASK=$(ifconfig eth0 | grep "inet " | cut -d " " -f13)
DNSSERVER=192.168.1.254
PXETOOLS=/usr/local/sbin/pxetools

echo "Resetting:"
echo "IP: $IP"
echo "Netmask: $NETMASK"
echo "Nameserver: $NAMESERVER"
echo "Gateway: $GATEWAY"
echo "DNS: $DNSSERVER"
echo "Pxettols: $PXETOOLS"

# exit

sudo systemctl stop dnsmasq
sudo systemctl disable dnsmasq
sudo rm /etc/dnsmasq.d/dnsmasq.conf

sudo rm -r /nfs
sudo rm -r /tftpboot

sudo rm $PXETOOLS
