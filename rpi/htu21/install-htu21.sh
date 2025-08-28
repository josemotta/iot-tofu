#!/bin/bash

#Add Htu21 humidity sensor.

set -e
cd "$(dirname "$0")"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

echo "---- Requirements"
apt install python3-pip
apt install i2c-tools
pip install --upgrade pip
pip install -r requirements.txt

echo "---- Configuration"
cp htu21.service /lib/systemd/system/htu21.service
rm -f -r /srv/htu21
mkdir /srv/htu21
cp -r . /srv/htu21

echo "---- Restart"
sudo systemctl daemon-reload
sudo systemctl enable htu21.service
sudo systemctl restart htu21.service

echo "---- Status"
sudo systemctl status htu21.service
