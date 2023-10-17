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

# This folder:
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

# Get network info. It should be already set!
NAMESERVER=$(cat /etc/resolv.conf | grep nameserver | head -n 1 | cut -d " " -f2)
GATEWAY=$(ip -4 route | grep default | head -n 1 | cut -d " " -f3)
IP=$(ifconfig eth0 | grep "inet " | cut -d " " -f10)
NETMASK=$(ifconfig eth0 | grep "inet " | cut -d " " -f13)
DNSSERVER=192.168.1.254
DHCPRANGE=192.168.10.50,192.168.10.99,255.255.255.0,12h
# BRD=$(ifconfig eth0 | grep "inet " | cut -d " " -f16)

# Setup files supposed to be in this folder:
PXETOOLS=$SCRIPT_DIR/pxetools.py      # app to add, remove & list RPis
CONFIG=$SCRIPT_DIR/config.txt         # default RPi config to be used in boot
FSGEN=$SCRIPT_DIR/fs-gen.sh           # fs generator - main
FSSSH=$SCRIPT_DIR/fs-ssh.sh           # fs generator - SSH host keys
PIPE=$SCRIPT_DIR/pipe.sh              # named pipe method to run commands
IMAGES=$SCRIPT_DIR/pxetools-images.sh # RPi OS bases to be downloaded

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

echo "Check values and cancel if not ok."

#	Network is not supposed to be changed down here
read -p "Cancel? (y/n) " RESP
if [ "$RESP" = "y" ]; then exit; fi

# Set a pipe to run commands from the docker container
# https://stackoverflow.com/questions/32163955/how-to-run-shell-script-on-host-from-docker-container
#
# jo@region2:~ $ echo "ls -l ~/pipe" > ~/pipe/pipe
# jo@region2:~ $ cat ~/pipe/pipe.txt
# total 8
# prw-r--r-- 1 jo jo  0 Oct 10 10:38 pipe
# -rw-r--r-- 1 jo jo 23 Oct 10 10:36 pipe.crontab
# -rwxr-xr-x 1 jo jo 78 Oct 10 10:36 pipe.sh
# -rw-r--r-- 1 jo jo  0 Oct 10 10:38 pipe.txt
# jo@region2:~ $ cat ~/pipe/pipe.crontab
# @reboot ~/pipe/pipe.sh
# jo@region2:~ $ cat ~/pipe/pipe.sh
# #!/bin/bash
# while true; do eval "$(cat ~/pipe/pipe)" &> ~/pipe/pipe.txt; done

mkdir ~/pipe && mkfifo ~/pipe/pipe
cat << EOF | tee ~/pipe/pipe.crontab
@reboot ~/pipe/pipe.sh
EOF

crontab -u $USER ~/pipe/pipe.crontab

cp --remove-destination $PIPE ~/pipe/pipe.sh
chmod +x ~/pipe/pipe.sh

# Set file systems
echo ""
echo "Creating system folders"
sudo mkdir -p /nfs
sudo mkdir -p /tftpboot
sudo cp -r /boot /tftpboot/base
sudo chmod -R 777 /tftpboot

# Apply files extracted from this folder & SSH
echo ""
echo "Applying files extracted from this folder"
sudo cp --remove-destination $CONFIG /tftpboot/base/config.txt
sudo cp --remove-destination $FSGEN /nfs/fs-gen.sh
sudo cp --remove-destination $FSSSH /nfs/fs-ssh.sh
sudo chmod +x /nfs/fs-gen.sh
sudo chmod +x /nfs/fs-ssh.sh
sudo touch /tftpboot/base/ssh

# Configure the default user for all RPis as $LOGNAME:$LOGNAME
# https://www.raspberrypi.com/documentation/computers/configuration.html#configuring-a-user
# sudo cat << EOF | tee /tftpboot/base/userconf.txt
# jo:$6$PL4aSoIKGMuiZ93i$iiqqVkexrkULJixXax/z/mL70HzTnawF9wtrqiqu6x2lPpKHikCR1xZF3rTb9Q2qNl81vV1nh1y9o3MxfQ/TC.:
# EOF
echo $USER:$(echo $USER | openssl passwd -6 -stdin) > /tftpboot/base/userconf.txt

echo ""
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

# Get Raspberry Pi OS images
echo ""
echo "Getting Raspberry Pi OS images"
if [ ! -d /nfs/bases ]; then
  source $IMAGES
fi

# Install pxetools
echo ""
echo "Installing pxetools"
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

echo ""
echo "Starting services"

# Disable DHCP client
sudo systemctl stop dhcpcd
sudo systemctl disable dhcpcd
sudo systemctl restart networking

# Start services
sudo systemctl enable dnsmasq rpcbind nfs-kernel-server
sudo systemctl restart dnsmasq rpcbind nfs-kernel-server

echo ""
echo "Now run sudo pxetools --add \$serial"
