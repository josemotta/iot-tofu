#!/bin/bash

# This folder:
# SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

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
# - there's no hash at known_hosts to speed up dev: hashknownhosts no

# owner
OWNER=$(<$BASE_FS/boot/owner)
RPI_USR_HOME=$BASE_FS/home/$OWNER
SRV_USR_HOME=/home/$OWNER
# hostname
RPI_HOSTNAME=$(<$BASE_FS/etc/hostname)
SRV_HOSTNAME=$(</etc/hostname)
# RPi owner user
RPI_USR_SSH=$RPI_USR_HOME/.ssh
RPI_USR_KNOWN_HOSTS=$RPI_USR_SSH/known_hosts
RPI_USR_AUTHORIZED_KEYS=$RPI_USR_SSH/authorized_keys
RPI_USR_KEY=$RPI_USR_SSH/id_rsa.pub
# RPi system wide
RPI_SYS=$BASE_FS/etc
RPI_SYS_SSH=$BASE_FS/etc/ssh
RPI_SYS_RSA_KEY=$RPI_SYS_SSH/ssh_host_rsa_key.pub
RPI_SYS_ECDSA_KEY=$RPI_SYS_SSH/ssh_host_ecdsa_key.pub
RPI_SYS_KNOWN_HOSTS=$RPI_SYS_SSH/ssh_known_hosts
# Boot server owner user
SRV_USR_SSH=$SRV_USR_HOME/.ssh
SRV_USR_KNOWN_HOSTS=$SRV_USR_SSH/known_hosts
SRV_USR_AUTHORIZED_KEYS=$SRV_USR_SSH/authorized_keys
SRV_USR_KEY=$SRV_USR_SSH/id_rsa.pub
# Boot server system wide
SRV_SYS=/etc
SRV_SYS_SSH=/etc/ssh
SRV_SYS_RSA_KEY=$SRV_SYS_SSH/ssh_host_rsa_key.pub
SRV_SYS_ECDSA_KEY=$SRV_SYS_SSH/ssh_host_ecdsa_key.pub
SRV_SYS_ED25519_KEY=$SRV_SYS_SSH/ssh_host_ed25519_key.pub
SRV_SYS_KNOWN_HOSTS=$SRV_SYS_SSH/ssh_known_hosts
# ssh config
RPI_SSH_CONFIG=$RPI_SYS_SSH/ssh_config.d
SRV_SSH_CONFIG=$SRV_SYS_SSH/ssh_config.d
# sshd config
RPI_SSHD_CONFIG=$RPI_SYS_SSH/sshd_config.d
SRV_SSHD_CONFIG=$SRV_SYS_SSH/sshd_config.d

#
# single hosts for all
#
cp -p /etc/hosts $BASE_FS/etc/hosts

#
# generate RPi owner rsa key
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
# https://www.golinuxcloud.com/configure-ssh-host-based-authentication-linux/
# https://stackoverflow.com/questions/29609371/how-not-to-pass-the-locale-through-an-ssh-connection-command
#
cat << EOF | sudo tee $RPI_SSH_CONFIG/config.conf
HashKnownHosts no
HostbasedAuthentication yes
EnableSSHKeysign yes
SendEnv -LC_* -LANG*
EOF

cat << EOF | sudo tee $SRV_SSH_CONFIG/config.conf
HashKnownHosts no
HostbasedAuthentication yes
EnableSSHKeysign yes
SendEnv -LC_* -LANG*
EOF

cat << EOF | sudo tee $RPI_SSHD_CONFIG/config.conf
HostbasedAuthentication yes
PubkeyAuthentication no
UseDNS no
IgnoreRhosts no
AcceptEnv -LC_* -LANG*
Match User $OWNER
  PasswordAuthentication no
  HostbasedAuthentication yes
#Match User rahul
#  HostbasedAuthentication no
#  PasswordAuthentication no
#  PubkeyAuthentication yes
Match all
  PasswordAuthentication yes
EOF

cat << EOF | sudo tee $SRV_SSHD_CONFIG/config.conf
HostbasedAuthentication yes
PubkeyAuthentication no
UseDNS no
IgnoreRhosts no
AcceptEnv -LC_* -LANG*
Match User $OWNER
  PasswordAuthentication no
  HostbasedAuthentication yes
#Match User rahul
#  HostbasedAuthentication no
#  PasswordAuthentication no
#  PubkeyAuthentication yes
Match all
  PasswordAuthentication yes
EOF

cat << EOF | sudo tee $RPI_SYS/shosts.equiv
rpi2
rpi4
region2
EOF

cat << EOF | sudo tee $SRV_SYS/shosts.equiv
rpi2
rpi4
region2
EOF

#
# known_hosts
#
if [ ! -f $RPI_USR_KNOWN_HOSTS ]; then
  touch $RPI_USR_KNOWN_HOSTS
  chmod 600 $RPI_USR_KNOWN_HOSTS
fi

if [ ! -f $RPI_SYS_KNOWN_HOSTS ]; then
  touch $RPI_SYS_KNOWN_HOSTS
  chmod 600 $RPI_SYS_KNOWN_HOSTS
fi

if [ ! -f $SRV_USR_KNOWN_HOSTS ]; then
  touch $SRV_USR_KNOWN_HOSTS
  chmod 600 $SRV_USR_KNOWN_HOSTS
fi

if [ ! -f $SRV_SYS_KNOWN_HOSTS ]; then
  if [ -d $SRV_USR_HOME/original-ssh ]; then
    cp -p $SRV_USR_HOME/original-ssh/known_hosts $SRV_SYS_KNOWN_HOSTS
  else
    touch $SRV_SYS_KNOWN_HOSTS
  fi
  chmod 600 $SRV_SYS_KNOWN_HOSTS
  KEYSTRING=$(<$SRV_SYS_RSA_KEY)
  echo "[$SRV_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
  KEYSTRING=$(<$SRV_SYS_ECDSA_KEY)
  echo "[$SRV_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
  KEYSTRING=$(<$SRV_SYS_ED25519_KEY)
  echo "[$SRV_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
  KEYSTRING=$(<$SRV_USR_KEY)
  echo "[$SRV_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
  # ssh-keygen -H -f $RPI_SYS_KNOWN_HOSTS
fi

#
# authorized_keys
#
if [ ! -f $RPI_USR_AUTHORIZED_KEYS ]; then
  touch $RPI_USR_AUTHORIZED_KEYS
  chmod 600 $RPI_USR_AUTHORIZED_KEYS
fi

if [ ! -f $SRV_USR_AUTHORIZED_KEYS ]; then
  touch $SRV_USR_AUTHORIZED_KEYS
  chmod 600 $SRV_USR_AUTHORIZED_KEYS
fi

# add RPi keys to both know_hosts & authorized_keys
KEYSTRING=$(<$RPI_SYS_RSA_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
KEYSTRING=$(<$RPI_SYS_ECDSA_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
KEYSTRING=$(<$RPI_USR_KEY)
echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
# ssh-keygen -H -f $SRV_SYS_KNOWN_HOSTS

cp -p $SRV_SYS_KNOWN_HOSTS $RPI_SYS_KNOWN_HOSTS
cp -p $SRV_SYS_KNOWN_HOSTS $RPI_USR_KNOWN_HOSTS
cp -p $SRV_SYS_KNOWN_HOSTS $SRV_USR_KNOWN_HOSTS
cp -p $SRV_SYS_KNOWN_HOSTS $SRV_USR_AUTHORIZED_KEYS
cp -p $SRV_SYS_KNOWN_HOSTS $RPI_USR_AUTHORIZED_KEYS

# # system-wide known_hosts: boot server -> rpi
# # $SRV_xxx_KEY ---> $BASE_FS/etc/ssh/known_hosts
# KEYSTRING=$(<$SRV_SYS_RSA_KEY)
# echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_SYS_KNOWN_HOSTS
# KEYSTRING=$(<$SRV_SYS_ECDSA_KEY)
# echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_SYS_KNOWN_HOSTS
# KEYSTRING=$(<$SRV_USR_KEY)
# echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_SYS_KNOWN_HOSTS
# # ssh-keygen -H -f $RPI_SYS_KNOWN_HOSTS

# # system-wide known_hosts: rpi -> boot server
# # $RPI_xxx_KEY ---> /etc/ssh/known_hosts
# KEYSTRING=$(<$RPI_SYS_RSA_KEY)
# echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
# KEYSTRING=$(<$RPI_SYS_ECDSA_KEY)
# echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
# KEYSTRING=$(<$RPI_USR_KEY)
# echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
# # ssh-keygen -H -f $SRV_SYS_KNOWN_HOSTS

# # local-client known_hosts: boot server -> rpi
# # $SRV_USR_KEY ---> $BASE_FS/home/$OWNER/.ssh/known_hosts
# KEYSTRING=$(<$SRV_SYS_RSA_KEY)
# echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_USR_KNOWN_HOSTS
# KEYSTRING=$(<$SRV_SYS_ECDSA_KEY)
# echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_USR_KNOWN_HOSTS
# KEYSTRING=$(<$SRV_USR_KEY)
# echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_USR_KNOWN_HOSTS
# # ssh-keygen -H -f $RPI_USR_KNOWN_HOSTS

# # local-client known_hosts: rpi -> boot server
# # $RPI_USR_KEY ---> ~/.ssh/known_hosts
# KEYSTRING=$(<$RPI_SYS_RSA_KEY)
# echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_USR_KNOWN_HOSTS
# KEYSTRING=$(<$RPI_SYS_ECDSA_KEY)
# echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_USR_KNOWN_HOSTS
# KEYSTRING=$(<$RPI_USR_KEY)
# echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_USR_KNOWN_HOSTS
# # ssh-keygen -H -f $SRV_USR_KNOWN_HOSTS

# # boot server -> rpi
# # $SRV_SYS_RSA_KEY ---> $BASE_FS/home/$OWNER/.ssh/authorized_keys
# KEYSTRING=$(<$SRV_SYS_RSA_KEY)
# echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_USR_AUTHORIZED_KEYS
# KEYSTRING=$(<$SRV_SYS_ECDSA_KEY)
# echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_USR_AUTHORIZED_KEYS
# KEYSTRING=$(<$SRV_USR_KEY)
# echo "[$SRV_HOSTNAME] $KEYSTRING" >> $RPI_USR_AUTHORIZED_KEYS
# # ssh-keygen -H -f $RPI_USR_AUTHORIZED_KEYS

# # rpi -> boot server
# # $RPI_SYS_RSA_KEY ---> ~/.ssh/authorized_keys
# KEYSTRING=$(<$RPI_SYS_RSA_KEY)
# echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_USR_AUTHORIZED_KEYS
# KEYSTRING=$(<$RPI_SYS_ECDSA_KEY)
# echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_USR_AUTHORIZED_KEYS
# KEYSTRING=$(<$RPI_USR_KEY)
# echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_USR_AUTHORIZED_KEYS
# # ssh-keygen -H -f $SRV_USR_AUTHORIZED_KEYS

# Keep user settings
chown $OWNER:$OWNER $RPI_USR_KNOWN_HOSTS
chown $OWNER:$OWNER $RPI_USR_AUTHORIZED_KEYS
chown $OWNER:$OWNER $SRV_USR_KNOWN_HOSTS
chown $OWNER:$OWNER $SRV_USR_AUTHORIZED_KEYS

# rm $RPI_USR_KNOWN_HOSTS.old
# rm $RPI_USR_AUTHORIZED_KEYS.old
# rm $SRV_USR_KNOWN_HOSTS.old
# rm $SRV_USR_AUTHORIZED_KEYS.old

systemctl restart sshd

# First try, not recognized as valid known_hosts format
#ssh-keygen -l -E md5 -f $RPI_SYS_RSA_KEY >> $SRV_SYS_KNOWN_HOSTS
