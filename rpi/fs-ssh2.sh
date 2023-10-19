#!/bin/bash

if [ $1 == "" ]; then
  echo Missing base fs
  exit 1
fi
export BASE_FS=$1

KEYS=$BASE_FS/etc/ssh/ssh_host_rsa_key.pub
OWNER=$(<$BASE_FS/boot/owner)
OWNER_HOME=$BASE_FS/home/$OWNER

#
# known_hosts
#

# copy boot server keys to rpi
# $KEYS ---> $BASE_FS/etc/ssh/known_hosts
echo ""
echo "rpi system-wide known_hosts setup"
touch $BASE_FS/etc/ssh/known_hosts
chmod 644 $BASE_FS/etc/ssh/known_hosts
ssh-keyscan -H -t rsa localhost >> $BASE_FS/etc/ssh/known_hosts

# copy rpi keys to boot server
# $KEYS ---> /etc/ssh/known_hosts
echo "boot server system-wide known_hosts setup"
if [ ! -d /etc/ssh/known_hosts ]; then
  touch /etc/ssh/known_hosts
  chmod 644 /etc/ssh/known_hosts
fi
ssh-keygen -l -E md5 -f $KEYS >> /etc/ssh/known_hosts

echo "boot server local-client known_hosts setup"
if [ ! -d ~/.ssh/known_hosts ]; then
  touch ~/.ssh/known_hosts
  chmod 644 ~/.ssh/known_hosts
fi
ssh-keygen -l -E md5 -f $KEYS >> ~/.ssh/known_hosts

#
# authorized_keys
#

# copy boot server keys to rpi
# $KEYS ---> $BASE_FS/$HOME/.ssh/authorized_keys
echo "rpi authorized_keys setup"
mkdir -p $BASE_FS/$HOME/.ssh
chmod 700 $BASE_FS/$HOME/.ssh
touch $BASE_FS/$HOME/.ssh/authorized_keys
chmod 600 $BASE_FS/$HOME/.ssh/authorized_keys
ssh-keyscan -H -t rsa localhost >> $BASE_FS/$HOME/.ssh/authorized_keys

# copy rpi keys to boot server
# $KEYS ---> $HOME/.ssh/authorized_keys
echo "boot server authorized_keys setup"
if [ ! -d $OWNER_HOME/.ssh/authorized_keys ]; then
  touch $OWNER_HOME/.ssh/authorized_keys
  chmod 644 $OWNER_HOME/.ssh/authorized_keys
fi
ssh-keygen -l -E md5 -f $KEYS >> $OWNER_HOME/.ssh/authorized_keys
