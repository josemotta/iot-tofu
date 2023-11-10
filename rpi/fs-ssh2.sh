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
# - setup has incremental changes that are added to every new RPi
# - side effect is that only last added RPi & boot server have full setup
# - to update the RPi setup just remove/add it again

# Boot server IP
SRV_IP=$(ifconfig eth0 | grep "inet " | cut -d " " -f10)
# owner, home & hostname
OWNER=$(<$BASE_FS/boot/owner)
RPI_USR_HOME=$BASE_FS/home/$OWNER
SRV_USR_HOME=/home/$OWNER
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
cp -p $SRV_SYS/hosts $RPI_SYS/hosts

#
# generate rsa key for RPi owner
#
if [ ! -f $SRV_USR_KEY ]; then
  echo Missing .ssh/id_rsa.pub at boot server for user: $OWNER
  exit 1
fi

# owner owns its home
if [ ! -d $RPI_USR_HOME ]; then
  mkdir -p $RPI_USR_HOME
  chown $OWNER:$OWNER $RPI_USR_HOME
  chmod 755 $RPI_USR_HOME
fi

if [ ! -d $RPI_USR_SSH ]; then
  mkdir -p $RPI_USR_SSH
  chown $OWNER:$OWNER $RPI_USR_SSH
  chmod 700 $RPI_USR_SSH
fi

if [ ! -f $RPI_USR_SSH/id_rsa ]; then
  ssh-keygen -q -t rsa -N '' -f $RPI_USR_SSH/id_rsa
  sleep 1
  chown $OWNER:$OWNER $RPI_USR_SSH/id_rsa*
fi

#
# enable host based authentication
#  - owner 'user' able to login with no passwords at boot server & all RPis
#  - trying to keep same setup for boot server & all RPis
#  - just need the ECDSA keys for host based authentication
#  - using a single file with all ECDSA keys for all known_hosts & authorized_keys
# https://www.golinuxcloud.com/configure-ssh-host-based-authentication-linux/
# https://stackoverflow.com/questions/29609371/how-not-to-pass-the-locale-through-an-ssh-connection-command
# https://www.iana.org/assignments/ssh-parameters/ssh-parameters.xhtml
#

if [ ! -f $SRV_SSH_CONFIG/config.conf ]; then
cat << EOF | sudo tee $SRV_SSH_CONFIG/config.conf
HashKnownHosts no
HostbasedAuthentication yes
EnableSSHKeysign yes
SendEnv -LC_* -LANG*
EOF
fi

if [ ! -f $RPI_SSH_CONFIG/config.conf ]; then
  sudo cp -p $SRV_SSH_CONFIG/config.conf $RPI_SSH_CONFIG/config.conf
fi

if [ ! -f $SRV_SSHD_CONFIG/config.conf ]; then
cat << EOF | sudo tee $SRV_SSHD_CONFIG/config.conf
HostbasedAuthentication yes
PubkeyAuthentication no
UseDNS yes
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
fi

if [ ! -f $RPI_SSHD_CONFIG/config.conf ]; then
  sudo cp -p $SRV_SSHD_CONFIG/config.conf $RPI_SSHD_CONFIG/config.conf
fi

# Add hostname setup where it does not exist

# /etc/shosts.equiv
if [ ! -f $SRV_SYS/shosts.equiv ]; then
  sudo echo "$SRV_HOSTNAME" >> $SRV_SYS/shosts.equiv
fi
case `grep -Fw "$RPI_HOSTNAME" "$SRV_SYS/shosts.equiv" >/dev/null; echo $?` in
  0)
    # found: do nothing
    ;;
  1)
    # not found: add RPi hostname
    sudo echo "$RPI_HOSTNAME" >> $SRV_SYS/shosts.equiv
    ;;
  *)
    # error: do nothing
    ;;
esac
sudo cp -p $SRV_SYS/shosts.equiv $RPI_SYS/shosts.equiv

# /etc/hosts.equiv
if [ ! -f $SRV_SYS/hosts.equiv ]; then
  sudo echo "$SRV_HOSTNAME $OWNER" >> $SRV_SYS/hosts.equiv
fi
case `grep -Fw "$RPI_HOSTNAME" "$SRV_SYS/hosts.equiv" >/dev/null; echo $?` in
  0)
    # found: do nothing
    ;;
  1)
    # not found: add RPi hostname
    sudo echo "$RPI_HOSTNAME $OWNER" >> $SRV_SYS/hosts.equiv
    ;;
  *)
    # error: do nothing
    ;;
esac
sudo cp -p $SRV_SYS/hosts.equiv $RPI_SYS/hosts.equiv

# Example: $RPI_SYS/hosts.equiv
#   region2 $OWNER
#   rpi2 $OWNER
#   rpi4 $OWNER

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
  # KEYSTRING=$(<$SRV_SYS_RSA_KEY)
  # echo "[$SRV_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
  KEYSTRING=$(<$SRV_SYS_ECDSA_KEY)
  echo "$SRV_HOSTNAME,$SRV_IP $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
  # KEYSTRING=$(<$SRV_SYS_ED25519_KEY)
  # echo "[$SRV_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
  # KEYSTRING=$(<$SRV_USR_KEY)
  # echo "[$SRV_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
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

# add key if it does not exist
case `grep -Fwq "$RPI_HOSTNAME" "$SRV_SYS_KNOWN_HOSTS" >/dev/null; echo $?` in
  0)
    # found: do nothing
    ;;
  1)
    # not found: add key
    KEYSTRING=$(<$RPI_SYS_ECDSA_KEY)
    echo "[$RPI_HOSTNAME] $KEYSTRING" >> $SRV_SYS_KNOWN_HOSTS
    ;;
  *)
    # error: do nothing
    ;;
esac

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

# Add rpi initialization
sudo cp /nfs/rpi-init.sh $RPI_USR_HOME
sudo chown $OWNER:$OWNER $RPI_USR_HOME/rpi-init.sh
sudo chmod +x $RPI_USR_HOME/rpi-init.sh

# Start services
systemctl restart sshd
