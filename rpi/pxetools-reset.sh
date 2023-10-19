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

echo "Resetting! Check values and cancel if not ok."
#	Network is not supposed to be changed down here
read -p "Cancel? (y/n) " RESP
if [ "$RESP" = "y" ]; then exit; fi

sudo systemctl stop dnsmasq
sudo systemctl disable dnsmasq
sudo rm /etc/dnsmasq.d/dnsmasq.conf
sudo rm /etc/exports
sudo rm $PXETOOLS

# Cleaning
# sudo rm -r /nfs
# keep bases to optimize image downloading (dev)
sudo rm -r /nfs/9f55bbfd
sudo rm -r /nfs/a10cd2e5
# boot
sudo rm -r /tftpboot
# pipe
crontab -r
sudo rm -r ~/pipe
sudo rm /etc/ssh/known_hosts
#sudo rm ~/.ssh/known_hosts
sudo rm ~/.ssh/authorized_keys

cat << EOF | sudo tee /etc/exports
# /etc/exports: the access control list for filesystems which may be exported
#		to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#
EOF
