#!/bin/bash

if [ $1 == "" ]; then
  echo Missing base fs
  exit 1
fi
export BASE_FS=$1

OWNER=$(<$BASE_FS/boot/owner)
KEY=ssh_host_rsa_key.pub

RPI_KEY=$BASE_FS/etc/ssh/$KEY
RPI_OWNER_HOME=$BASE_FS/home/$OWNER
RPI_AUTHORIZED_KEYS=$RPI_OWNER_HOME/.ssh/authorized_keys

SRV_KEY=/etc/ssh/$KEY
SRV_OWNER_HOME=/home/$OWNER
SRV_AUTHORIZED_KEYS=$SRV_OWNER_HOME/.ssh/authorized_keys
SRV_KNOWN_HOSTS=$SRV_OWNER_HOME/.ssh/known_hosts

#
# known_hosts
#

# rpi system-wide known_hosts: boot server -> rpi
# $SRV_KEY ---> $BASE_FS/etc/ssh/known_hosts
touch $BASE_FS/etc/ssh/known_hosts
chmod 644 $BASE_FS/etc/ssh/known_hosts
ssh-keygen -l -E md5 -f $SRV_KEY >> $BASE_FS/etc/ssh/known_hosts

# boot server system-wide known_hosts: rpi -> boot server
# $RPI_KEY ---> /etc/ssh/known_hosts
if [ ! -d /etc/ssh/known_hosts ]; then
  touch /etc/ssh/known_hosts
  chmod 644 /etc/ssh/known_hosts
fi
ssh-keygen -l -E md5 -f $RPI_KEY >> /etc/ssh/known_hosts

# boot server local-client known_hosts: rpi -> boot server
# $RPI_KEY ---> ~/.ssh/known_hosts
if [ ! -d $SRV_KNOWN_HOSTS ]; then
  touch $SRV_KNOWN_HOSTS
  chmod 644 $SRV_KNOWN_HOSTS
fi
ssh-keygen -l -E md5 -f $RPI_KEY >> $SRV_KNOWN_HOSTS

#
# authorized_keys
#

# boot server -> rpi
# $SRV_KEY ---> $BASE_FS/home/$OWNER/.ssh/authorized_keys
mkdir -p $RPI_OWNER_HOME/.ssh
chmod 700 $RPI_OWNER_HOME/.ssh
touch $RPI_AUTHORIZED_KEYS
chmod 600 $RPI_AUTHORIZED_KEYS
ssh-keygen -l -E md5 -f $SRV_KEY >> $RPI_AUTHORIZED_KEYS

# rpi -> boot server
# $RPI_KEY ---> ~/.ssh/authorized_keys
if [ ! -d $SRV_AUTHORIZED_KEYS ]; then
  touch $SRV_AUTHORIZED_KEYS
  chmod 644 $SRV_AUTHORIZED_KEYS
fi
ssh-keygen -l -E md5 -f $RPI_KEY >> $SRV_AUTHORIZED_KEYS
