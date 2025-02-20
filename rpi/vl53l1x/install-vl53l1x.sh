#!/bin/bash

#Add VL53L1X Time-of-Flight (ToF) laser-ranging sensor.

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
cp vl53l1x.service /lib/systemd/system/vl53l1x.service
rm -f /srv/vl53l1x
mkdir /srv/vl53l1x
cp -r . /srv/vl53l1x

echo "---- Restart"
sudo systemctl daemon-reload
sudo systemctl enable vl53l1x.service
sudo systemctl restart vl53l1x.service

echo "---- Status"
sudo systemctl status vl53l1x.service
