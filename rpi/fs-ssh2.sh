#!/bin/bash

if [ $1 == "" ]; then
  echo Missing base fs
  exit 1
fi
export BASE_FS=$1

KEYS='/etc/ssh/ssh_host_*'

#
# known_hosts
#

# copy boot server keys to rpi
# $KEYS ---> $BASE_FS/etc/ssh/known_hosts

# copy rpi keys to boot server
# $BASE_FS/$KEYS ---> ~/.ssh/known_hosts

#
# authorized_keys
#

# copy boot server keys to rpi
# $KEYS ---> $BASE_FS/home/$USER/.ssh/authorized_keys

# copy rpi keys to boot server
# $BASE_FS/$KEYS ---> ~/.ssh/authorized_keys
