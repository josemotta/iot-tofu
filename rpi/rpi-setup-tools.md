# RPi setup

## dev tools

```sh
sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash - &&sudo apt-get install -y nodejs

sudo npm install -g npm@9.8.1

sudo npm i -g @looback/cli
```

## Available for RPi and PC

IBM Loopback allows the same API source code for rpi (aarch64) & pc (x86_64).

### rpi (aarch64)

```sh
{
  "greeting": "Hello from LoopBack",
  "date": "2023-07-21T15:04:11.139Z",
  "url": "/ping",
  "headers": {
    "host": "localhost:3000",
    "connection": "keep-alive",
    "sec-ch-ua": "\"Chromium\";v=\"113\", \"Not-A.Brand\";v=\"24\"",
    "accept": "application/json",
    "sec-ch-ua-mobile": "?0",
    "user-agent": "Mozilla/5.0 (X11; CrOS aarch64 13597.84.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.5672.95 Safari/537.36",
    "sec-ch-ua-platform": "\"Linux\"",
    "sec-fetch-site": "same-origin",
    "sec-fetch-mode": "cors",
    "sec-fetch-dest": "empty",
    "referer": "http://localhost:3000/explorer/",
    "accept-encoding": "gzip, deflate, br",
    "accept-language": "en-GB,en-US;q=0.9,en;q=0.8"
  }
}
```

### pc (x86_64)

```sh
{
  "greeting": "Hello from LoopBack",
  "date": "2023-07-21T19:55:01.819Z",
  "url": "/ping",
  "headers": {
    "host": "localhost:3000",
    "connection": "keep-alive",
    "sec-ch-ua": "\"Google Chrome\";v=\"107\", \"Chromium\";v=\"107\", \"Not=A?Brand\";v=\"24\"",
    "accept": "application/json",
    "dnt": "1",
    "sec-ch-ua-mobile": "?0",
    "user-agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
    "sec-ch-ua-platform": "\"Linux\"",
    "sec-fetch-site": "same-origin",
    "sec-fetch-mode": "cors",
    "sec-fetch-dest": "empty",
    "referer": "http://localhost:3000/explorer/",
    "accept-encoding": "gzip, deflate, br",
    "accept-language": "en,pt-BR;q=0.9,pt;q=0.8"
  }
}
```

## nvme.m2

```sh
# FORMAT NVME
# https://www.raspberrypi.com/documentation/computers/compute-module.html#writing-to-the-emmc-linux

sudo dd if=raw_os_image_of_your_choice.img of=/dev/nvme0n1 bs=4MiB

# mount -l
/dev/nvme0n1p1 on /boot type vfat (rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro) [bootfs]
/dev/nvme0n1p2 on / type ext4 (rw,noatime) [rootfs]

/dev/mmcblk0p1 on /media/jo/bootfs type vfat (rw,nosuid,nodev,relatime,uid=1000,gid=1000,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,showexec,utf8,flush,errors=remount-ro,uhelper=udisks2) [bootfs]
/dev/mmcblk0p2 on /media/jo/rootfs type ext4 (rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2) [rootfs]
```

## utils

```sh
# Regenerate SSH host keys on the client filesystem
# by chrooting into it
cd /nfs/client1
sudo mount --bind /dev dev
sudo mount --bind /sys sys
sudo mount --bind /proc proc
sudo chroot .
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server
exit
sudo umount dev sys proc

# Find the address of your router (or gateway)
ip route | awk '/default/ {print $3}'

# dnsmasq
# dnsmasq is free software providing Domain Name System caching, a
# Dynamic Host Configuration Protocol server, router advertisement
# and network boot features, intended for small computer networks.

sudo apt install tcpdump dnsmasq
sudo systemctl enable dnsmasq
sudo tcpdump -i eth0 port bootpc
```

## CLIENT_ID ops

```sh
# SERVER STEPS
#---------------------------------
# server-step-fsdel $1
#---------------------------------
if [ $1 == "" ]; then
  echo "Missing client id"
  exit 1
fi
export CLIENT_ID=$1
sudo rm -r /nfs/$CLIENT_ID

#---------------------------------
# server-step-fsgen $1
#---------------------------------
if [ $1 == "" ]; then
  echo "Missing client id"
  exit 1
fi
export CLIENT_ID=$1
# Generate a copy from current fs to $CLIENT_ID
sudo mkdir -p /nfs/$CLIENT_ID
sudo apt install rsync
sudo rsync -xa --progress --exclude /nfs / /nfs/$CLIENT_ID

# Regenerate SSH host keys on the CLIENT_ID filesystem
# by chrooting into it
cd /nfs/$CLIENT_ID
sudo mount --bind /dev dev
sudo mount --bind /sys sys
sudo mount --bind /proc proc
sudo chroot .
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server
exit
sudo umount dev sys proc

```
