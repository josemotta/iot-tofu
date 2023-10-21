#!/bin/bash

if [ $1 == "" ]; then
  echo Missing base fs
  exit 1
fi
export BASE_FS=$1

# SSH setup for known_hosts & authorized_keys files
# - There are system-wide & owner-user 'known-hosts' for RPi & boot server
# - There are owner-user 'authorized_keys' for RPi & boot server
# Notes:
# - Owner user at boot server should supply a rsa key: ~/.ssh/id_rsa.pub
# - Owner account name is a parameter set by pxetools: /boot/owner
# - RPi hostname is a parameter set by pxetools: /boot/name == /etc/hostname

OWNER=$(<$BASE_FS/boot/owner)
RPI_HOSTNAME=$(<$BASE_FS/etc/hostname)
SRV_HOSTNAME=$(</etc/hostname)

RPI_USR_HOME=$BASE_FS/home/$OWNER
RPI_USR_KNOWN_HOSTS=$RPI_USR_HOME/.ssh/known_hosts
RPI_USR_AUTHORIZED_KEYS=$RPI_USR_HOME/.ssh/authorized_keys
RPI_USR_KEY=$RPI_USR_HOME/.ssh/id_rsa.pub
RPI_SYS_KEY=$BASE_FS/etc/ssh/ssh_host_rsa_key.pub
RPI_SYS_KNOWN_HOSTS=$BASE_FS/etc/ssh/ssh_known_hosts

SRV_USR_HOME=/home/$OWNER
SRV_USR_KNOWN_HOSTS=$SRV_USR_HOME/.ssh/known_hosts
SRV_USR_AUTHORIZED_KEYS=$SRV_USR_HOME/.ssh/authorized_keys
SRV_USR_KEY=$SRV_USR_HOME/.ssh/id_rsa.pub
SRV_SYS_KEY=/etc/ssh/ssh_host_rsa_key.pub
SRV_SYS_KNOWN_HOSTS=/etc/ssh/ssh_known_hosts

#
# .ssh
#
if [ ! -f $SRV_USR_KEY ]; then
  echo Missing .ssh/id_rsa.pub at boot server for user: $OWNER
  exit 1
fi

if [ ! -d $RPI_USR_HOME/.ssh ]; then
  mkdir -p $RPI_USR_HOME/.ssh
  chown $OWNER:$OWNER $RPI_USR_HOME/.ssh
  chmod 700 $RPI_USR_HOME/.ssh
fi

#
# known_hosts
#
if [ ! -f $RPI_USR_KNOWN_HOSTS ]; then
  touch $RPI_USR_KNOWN_HOSTS
  chmod 644 $RPI_USR_KNOWN_HOSTS
  chown $OWNER:$OWNER $RPI_USR_KNOWN_HOSTS
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
  chown $OWNER:$OWNER $SRV_USR_KNOWN_HOSTS
fi

# rpi system-wide known_hosts: boot server -> rpi
# $SRV_SYS_KEY ---> $BASE_FS/etc/ssh/known_hosts
#ssh-keygen -l -E md5 -f $SRV_SYS_KEY >> $RPI_SYS_KNOWN_HOSTS
KEYSTRING=$(<$SRV_SYS_KEY)
echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_SYS_KNOWN_HOSTS
ssh-keygen -H -f $RPI_SYS_KNOWN_HOSTS

# boot server system-wide known_hosts: rpi -> boot server
# $RPI_SYS_KEY ---> /etc/ssh/known_hosts
#ssh-keygen -l -E md5 -f $RPI_SYS_KEY >> $SRV_SYS_KNOWN_HOSTS
KEYSTRING=$(<$RPI_SYS_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
ssh-keygen -H -f $SRV_SYS_KNOWN_HOSTS

# boot server local-client known_hosts: rpi -> boot server
# $RPI_SYS_KEY ---> ~/.ssh/known_hosts
#ssh-keygen -l -E md5 -f $RPI_SYS_KEY >> $SRV_USR_KNOWN_HOSTS
KEYSTRING=$(<$RPI_SYS_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_USR_KNOWN_HOSTS
ssh-keygen -H -f $SRV_USR_KNOWN_HOSTS
chown $OWNER:$OWNER $SRV_USR_KNOWN_HOSTS

#
# authorized_keys
#
if [ ! -f $SRV_USR_AUTHORIZED_KEYS ]; then
  touch $SRV_USR_AUTHORIZED_KEYS
  chmod 644 $SRV_USR_AUTHORIZED_KEYS
  chown $OWNER:$OWNER $SRV_USR_AUTHORIZED_KEYS
fi

if [ ! -f $RPI_USR_AUTHORIZED_KEYS ]; then
  touch $RPI_USR_AUTHORIZED_KEYS
  chmod 644 $RPI_USR_AUTHORIZED_KEYS
  chown $OWNER:$OWNER $RPI_USR_AUTHORIZED_KEYS
fi

# boot server -> rpi
# $SRV_SYS_KEY ---> $BASE_FS/home/$OWNER/.ssh/authorized_keys
#ssh-keygen -l -E md5 -f $SRV_SYS_KEY >> $RPI_USR_AUTHORIZED_KEYS
KEYSTRING=$(<$SRV_SYS_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $RPI_USR_AUTHORIZED_KEYS
ssh-keygen -H -f $RPI_USR_AUTHORIZED_KEYS
chown $OWNER:$OWNER $RPI_USR_AUTHORIZED_KEYS

# rpi -> boot server
# $RPI_SYS_KEY ---> ~/.ssh/authorized_keys
#ssh-keygen -l -E md5 -f $RPI_SYS_KEY >> $SRV_USR_AUTHORIZED_KEYS
KEYSTRING=$(<$RPI_SYS_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_USR_AUTHORIZED_KEYS
ssh-keygen -H -f $SRV_USR_AUTHORIZED_KEYS
chown $OWNER:$OWNER $SRV_USR_AUTHORIZED_KEYS
