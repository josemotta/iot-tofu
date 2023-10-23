#!/bin/bash

# This folder:
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

if [ $1 == "" ]; then
  echo Missing base fs
  exit 1
fi
export BASE_FS=$1

# Initial SSH setup: known_hosts & authorized_keys for region network
# - Owner user at boot server SHOULD supply the rsa key: ~/.ssh/id_rsa.pub
# - Generates rsa key for RPi owner user
# - Generates system-wide & owner-user 'known-hosts' for RPi & boot server
# - Generates 'authorized_keys' for RPi & boot server
# Notes:
# - Owner account name is a parameter set by pxetools: /boot/owner
# - RPi hostname is a parameter set by pxetools: /boot/name == /etc/hostname

OWNER=$(<$BASE_FS/boot/owner)
RPI_HOSTNAME=$(<$BASE_FS/etc/hostname)
SRV_HOSTNAME=$(</etc/hostname)

RPI_USR_HOME=$BASE_FS/home/$OWNER
RPI_USR_SSH=$RPI_USR_HOME/.ssh
RPI_USR_KNOWN_HOSTS=$RPI_USR_SSH/known_hosts
RPI_USR_AUTHORIZED_KEYS=$RPI_USR_SSH/authorized_keys
RPI_USR_KEY=$RPI_USR_SSH/id_rsa.pub
RPI_SYS_KEY=$BASE_FS/etc/ssh/ssh_host_rsa_key.pub
RPI_SYS_KNOWN_HOSTS=$BASE_FS/etc/ssh/ssh_known_hosts

SRV_USR_HOME=/home/$OWNER
SRV_USR_SSH=$SRV_USR_HOME/.ssh
SRV_USR_KNOWN_HOSTS=$SRV_USR_SSH/known_hosts
SRV_USR_AUTHORIZED_KEYS=$SRV_USR_SSH/authorized_keys
SRV_USR_KEY=$SRV_USR_SSH/id_rsa.pub
SRV_SYS_KEY=/etc/ssh/ssh_host_rsa_key.pub
SRV_SYS_KNOWN_HOSTS=/etc/ssh/ssh_known_hosts

RPI_SSH_CONFIG=$RPI_USR_SSH/ssh_config.d
SRV_SSH_CONFIG=$SRV_USR_SSH/ssh_config.d

#
# .ssh & RPi owner key
#
if [ ! -f $SRV_USR_KEY ]; then
  echo Missing .ssh/id_rsa.pub at boot server for user: $OWNER
  exit 1
fi

if [ ! -d $RPI_USR_SSH ]; then
  mkdir -p $RPI_USR_SSH
  chown $OWNER:$OWNER $RPI_USR_SSH
  chmod 700 $RPI_USR_SSH
fi

ssh-keygen -q -t rsa -N '' -f $RPI_USR_SSH/id_rsa
sleep 1
chown $OWNER:$OWNER $RPI_USR_SSH/id_rsa*

#
# enable host based authentication
#
cp $SCRIPT_DIR/ssh_config.conf $RPI_SSH_CONFIG/config.conf
cp $SCRIPT_DIR/ssh_config.conf $SRV_SSH_CONFIG/config.conf

#
# known_hosts
#
if [ ! -f $RPI_USR_KNOWN_HOSTS ]; then
  touch $RPI_USR_KNOWN_HOSTS
  chmod 644 $RPI_USR_KNOWN_HOSTS
fi

if [ ! -f $RPI_SYS_KNOWN_HOSTS ]; then
  touch $RPI_SYS_KNOWN_HOSTS
  chmod 644 $RPI_SYS_KNOWN_HOSTS
fi

if [ ! -f $SRV_SYS_KNOWN_HOSTS ]; then
  touch $SRV_SYS_KNOWN_HOSTS
  chmod 644 $SRV_SYS_KNOWN_HOSTS
fi

if [ ! -f $SRV_USR_KNOWN_HOSTS ]; then
  touch $SRV_USR_KNOWN_HOSTS
  chmod 644 $SRV_USR_KNOWN_HOSTS
fi

# system-wide known_hosts: boot server -> rpi
# $SRV_xxx_KEY ---> $BASE_FS/etc/ssh/known_hosts
KEYSTRING=$(<$SRV_SYS_KEY)
echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_SYS_KNOWN_HOSTS
KEYSTRING=$(<$SRV_USR_KEY)
echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_SYS_KNOWN_HOSTS
ssh-keygen -H -f $RPI_SYS_KNOWN_HOSTS

# system-wide known_hosts: rpi -> boot server
# $RPI_xxx_KEY ---> /etc/ssh/known_hosts
KEYSTRING=$(<$RPI_SYS_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
KEYSTRING=$(<$RPI_USR_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
ssh-keygen -H -f $SRV_SYS_KNOWN_HOSTS

# local-client known_hosts: boot server -> rpi
# $SRV_USR_KEY ---> $BASE_FS/home/$OWNER/.ssh/known_hosts
KEYSTRING=$(<$SRV_USR_KEY)
echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_USR_KNOWN_HOSTS
ssh-keygen -H -f $RPI_USR_KNOWN_HOSTS

# local-client known_hosts: rpi -> boot server
# $RPI_USR_KEY ---> ~/.ssh/known_hosts
KEYSTRING=$(<$RPI_USR_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_USR_KNOWN_HOSTS
ssh-keygen -H -f $SRV_USR_KNOWN_HOSTS

#
# authorized_keys
#
if [ ! -f $SRV_USR_AUTHORIZED_KEYS ]; then
  touch $SRV_USR_AUTHORIZED_KEYS
  chmod 644 $SRV_USR_AUTHORIZED_KEYS
fi

if [ ! -f $RPI_USR_AUTHORIZED_KEYS ]; then
  touch $RPI_USR_AUTHORIZED_KEYS
  chmod 644 $RPI_USR_AUTHORIZED_KEYS
fi

# boot server -> rpi
# $SRV_SYS_KEY ---> $BASE_FS/home/$OWNER/.ssh/authorized_keys
KEYSTRING=$(<$SRV_SYS_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $RPI_USR_AUTHORIZED_KEYS
KEYSTRING=$(<$SRV_USR_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $RPI_USR_AUTHORIZED_KEYS
ssh-keygen -H -f $RPI_USR_AUTHORIZED_KEYS

# rpi -> boot server
# $RPI_SYS_KEY ---> ~/.ssh/authorized_keys
KEYSTRING=$(<$RPI_SYS_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_USR_AUTHORIZED_KEYS
KEYSTRING=$(<$RPI_USR_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_USR_AUTHORIZED_KEYS
ssh-keygen -H -f $SRV_USR_AUTHORIZED_KEYS

# Keep user settings
chown $OWNER:$OWNER $RPI_USR_KNOWN_HOSTS
chown $OWNER:$OWNER $RPI_USR_AUTHORIZED_KEYS
chown $OWNER:$OWNER $SRV_USR_KNOWN_HOSTS
chown $OWNER:$OWNER $SRV_USR_AUTHORIZED_KEYS

rm $RPI_USR_KNOWN_HOSTS.old
rm $RPI_USR_AUTHORIZED_KEYS.old
rm $SRV_USR_KNOWN_HOSTS.old
rm $SRV_USR_AUTHORIZED_KEYS.old

# First try, not recognized as valid known_hosts format
#ssh-keygen -l -E md5 -f $RPI_SYS_KEY >> $SRV_SYS_KNOWN_HOSTS
