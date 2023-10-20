#!/bin/bash

if [ $1 == "" ]; then
  echo Missing base fs
  exit 1
fi
export BASE_FS=$1

OWNER=$(<$BASE_FS/boot/owner)

RPI_USR_HOME=$BASE_FS/home/$OWNER
RPI_USR_AUTHORIZED_KEYS=$RPI_USR_HOME/.ssh/authorized_keys
RPI_USR_KNOWN_HOSTS=$RPI_USR_HOME/.ssh/known_hosts
RPI_USR_KEY=$RPI_USR_HOME/.ssh/id_rsa.pub
RPI_SYS_KEY=$BASE_FS/etc/ssh/ssh_host_rsa_key.pub
RPI_SYS_KNOWN_HOSTS=$BASE_FS/etc/ssh/known_hosts

SRV_USR_HOME=/home/$OWNER
SRV_USR_AUTHORIZED_KEYS=$SRV_USR_HOME/.ssh/authorized_keys
SRV_USR_KNOWN_HOSTS=$SRV_USR_HOME/.ssh/known_hosts
SRV_USR_KEY=$SRV_USR_HOME/.ssh/id_rsa.pub
SRV_SYS_KEY=/etc/ssh/ssh_host_rsa_key.pub
SRV_SYS_KNOWN_HOSTS=/etc/ssh/known_hosts

#
# known_hosts
#

# rpi system-wide known_hosts: boot server -> rpi
# $SRV_SYS_KEY ---> $BASE_FS/etc/ssh/known_hosts
touch $RPI_SYS_KNOWN_HOSTS
chmod 644 $RPI_SYS_KNOWN_HOSTS
ssh-keygen -l -E md5 -f $SRV_SYS_KEY >> $RPI_SYS_KNOWN_HOSTS

# boot server system-wide known_hosts: rpi -> boot server
# $RPI_SYS_KEY ---> /etc/ssh/known_hosts
if [ ! -d $SRV_SYS_KNOWN_HOSTS ]; then
  touch $SRV_SYS_KNOWN_HOSTS
  chmod 644 $SRV_SYS_KNOWN_HOSTS
fi
ssh-keygen -l -E md5 -f $RPI_SYS_KEY >> $SRV_SYS_KNOWN_HOSTS

# boot server local-client known_hosts: rpi -> boot server
# $RPI_SYS_KEY ---> ~/.ssh/known_hosts
if [ ! -d $SRV_USR_KNOWN_HOSTS ]; then
  touch $SRV_USR_KNOWN_HOSTS
  chmod 644 $SRV_USR_KNOWN_HOSTS
fi
ssh-keygen -l -E md5 -f $RPI_SYS_KEY >> $SRV_USR_KNOWN_HOSTS

#
# authorized_keys
#

# boot server -> rpi
# $SRV_SYS_KEY ---> $BASE_FS/home/$OWNER/.ssh/authorized_keys
mkdir -p $RPI_USR_HOME/.ssh
chmod 700 $RPI_USR_HOME/.ssh
touch $RPI_USR_AUTHORIZED_KEYS
chmod 600 $RPI_USR_AUTHORIZED_KEYS
ssh-keygen -l -E md5 -f $SRV_SYS_KEY >> $RPI_USR_AUTHORIZED_KEYS

# rpi -> boot server
# $RPI_SYS_KEY ---> ~/.ssh/authorized_keys
if [ ! -d $SRV_USR_AUTHORIZED_KEYS ]; then
  touch $SRV_USR_AUTHORIZED_KEYS
  chmod 644 $SRV_USR_AUTHORIZED_KEYS
fi
ssh-keygen -l -E md5 -f $RPI_SYS_KEY >> $SRV_USR_AUTHORIZED_KEYS
