#!/bin/bash

if [ $1 == "" ]; then
  echo Missing base fs
  exit 1
fi
export BASE_FS=$1

KEYS=$BASE_FS/etc/ssh/ssh_host_rsa_key.pub

#
# known_hosts
#

# copy boot server keys to rpi
# $KEYS ---> $BASE_FS/etc/ssh/known_hosts
touch $BASE_FS/etc/ssh/known_hosts
chmod 644 $BASE_FS/etc/ssh/known_hosts
ssh-keyscan -H -t rsa localhost >> $BASE_FS/etc/ssh/known_hosts

# copy rpi keys to boot server
# $BASE_FS/$KEYS ---> /etc/ssh/known_hosts
if [ ! -d /etc/ssh/known_hosts ]; then
  touch /etc/ssh/known_hosts
  chmod 644 /etc/ssh/known_hosts
fi
cat $KEYS >> /etc/ssh/known_hosts

#
# authorized_keys
#

# copy boot server keys to rpi
# $KEYS ---> $BASE_FS/$HOME/.ssh/authorized_keys
mkdir -p $BASE_FS/$HOME/.ssh
chmod 700 $BASE_FS/$HOME/.ssh
touch $BASE_FS/$HOME/.ssh/authorized_keys
chmod 600 $BASE_FS/$HOME/.ssh/authorized_keys
ssh-keyscan -H -t rsa localhost >> $BASE_FS/$HOME/.ssh/authorized_keys

# copy rpi keys to boot server
# $BASE_FS/$KEYS ---> ~/.ssh/authorized_keys
if [ ! -d ~/.ssh/authorized_keys ]; then
  touch ~/.ssh/authorized_keys
  chmod 644 ~/.ssh/authorized_keys
fi
cat $KEYS >> ~/.ssh/authorized_keys
