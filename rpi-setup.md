
```sh
# Create swapfile

jo@region ~ $ sudo fallocate -l 2G /var/swapfile
jo@region ~ $ ls -lh /var/swapfile 
-rw-r--r-- 1 root root 2.0G Aug 15 17:18 /var/swapfile
jo@region ~ $ sudo chmod 600 /var/swapfile
jo@region ~ $ ls -lh /var/swapfile 
-rw------- 1 root root 2.0G Aug 15 17:18 /var/swapfile
jo@region ~ $ sudo mkswap /var/swapfile
Setting up swapspace version 1, size = 2 GiB (2147479552 bytes)
no label, UUID=518267f9-5b00-4961-8a21-eefc49183f35
jo@region ~ $ sudo swapon /var/swapfile
jo@region ~ $ sudo swapon --show
NAME          TYPE SIZE USED PRIO
/var/swap     file 100M   0B   -2
/var/swapfile file   2G   0B   -3
jo@region ~ $ free -h
               total        used        free      shared  buff/cache   available
Mem:           1.8Gi       326Mi       1.0Gi        82Mi       496Mi       1.3Gi
Swap:          2.1Gi          0B       2.1Gi

jo@region ~ $ cat /etc/dphys-swapfile 
# /etc/dphys-swapfile - user settings for dphys-swapfile package
# author Neil Franklin, last modification 2010.05.05
# copyright ETH Zuerich Physics Departement
#   use under either modified/non-advertising BSD or GPL license

# this file is sourced with . so full normal sh syntax applies

# the default settings are added as commented out CONF_*=* lines


# where we want the swapfile to be, this is the default
CONF_SWAPFILE=/var/swapfile

# set size to absolute value, leaving empty (default) then uses computed value
#   you most likely don't want this, unless you have an special disk situation
CONF_SWAPSIZE=2048

# set size to computed value, this times RAM size, dynamically adapts,
#   guarantees that there is enough swap without wasting disk space on excess
#CONF_SWAPFACTOR=2

# restrict size (computed and absolute!) to maximally this limit
#   can be set to empty for no limit, but beware of filled partitions!
#   this is/was a (outdated?) 32bit kernel limit (in MBytes), do not overrun it
#   but is also sensible on 64bit to prevent filling /var or even / partition
#CONF_MAXSWAP=2048

jo@region ~ $ sudo dphys-swapfile swapoff
Usage: /usr/sbin/dphys-swapfile {setup|swapon|swapoff|uninstall}
jo@region ~ $ sudo dphys-swapfile setup
want /var/swapfile=2048MByte, checking existing: keeping it
jo@region ~ $ sudo dphys-swapfile swapon
jo@region ~ $ sudo swapon --show
NAME          TYPE SIZE USED PRIO
/var/swap     file 100M   0B   -2
/var/swapfile file   2G   0B   -3
jo@region ~ $ free -h
               total        used        free      shared  buff/cache   available
Mem:           1.8Gi       695Mi       402Mi       156Mi       751Mi       913Mi
Swap:          2.1Gi          0B       2.1Gi

```