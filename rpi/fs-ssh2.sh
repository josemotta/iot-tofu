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
echo ""
echo "rpi known_hosts setup"
touch $BASE_FS/etc/ssh/known_hosts
chmod 644 $BASE_FS/etc/ssh/known_hosts
ssh-keyscan -H -t rsa localhost >> $BASE_FS/etc/ssh/known_hosts

# copy rpi keys to boot server
# $KEYS ---> /etc/ssh/known_hosts
echo "boot server known_hosts setup"
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
echo "rpi authorized_keys setup"
mkdir -p $BASE_FS/$HOME/.ssh
chmod 700 $BASE_FS/$HOME/.ssh
touch $BASE_FS/$HOME/.ssh/authorized_keys
chmod 600 $BASE_FS/$HOME/.ssh/authorized_keys
ssh-keyscan -H -t rsa localhost >> $BASE_FS/$HOME/.ssh/authorized_keys

# copy rpi keys to boot server
# $KEYS ---> $HOME/.ssh/authorized_keys
echo "boot server authorized_keys setup"
if [ ! -d /home/jo/.ssh/authorized_keys ]; then
  touch /home/jo/.ssh/authorized_keys
  chmod 644 /home/jo/.ssh/authorized_keys
fi
cat $KEYS >> /home/jo/.ssh/authorized_keys
