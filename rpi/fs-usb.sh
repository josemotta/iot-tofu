#!/bin/bash

# This folder:
# SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

if [ $1 == "" ]; then
  echo Missing base fs
  exit 1
fi
export BASE_FS=$1

# Format USB storage for docker

RPI_OPT=$BASE_FS/opt
RPI_SYSTEMD=$BASE_FS/etc/systemd/system

cat <<EOF | sudo tee $RPI_OPT/setusb.sh
#!/bin/bash
if [ ! -b /dev/sda ]; then
echo "No USB detected"
exit 1
fi

sudo sfdisk /dev/sda <<EOFF
;
EOFF

if [ "$?" != "0" ]; then
exit 1
fi

sudo mkfs.ext4 -F /dev/sda1
sudo mount /var/lib/docker
EOF

sudo chmod +x $RPI_OPT/setusb.sh

cat <<EOF | sudo tee $RPI_SYSTEMD/setusb.service
[Unit]
Description=Format USB storage for docker.
Wants=network-online.target
After=network-online.target
After=remote-fs.target
After=time-sync.target

[Service]
Type=oneshot
ExecStart=/opt/setusb.sh

[Install]
WantedBy=multi-user.target
EOF

sudo ln -s $RPI_SYSTEMD/setusb.service $RPI_SYSTEMD/multi-user.target.wants/setusb.service
