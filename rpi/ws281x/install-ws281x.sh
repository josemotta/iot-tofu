#!/bin/bash
set -e
cd "$(dirname "$0")"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

echo "---- Requirements"
apt install python3-pip
pip install --upgrade pip
pip install -r requirements.txt

echo "---- Configuration"
cp ws281x.service /lib/systemd/system/ws281x.service
rm -r /srv/ws281x
mkdir /srv/ws281x
cp -r . /srv/ws281x

echo "---- Restart"
sudo systemctl daemon-reload
sudo systemctl enable ws281x.service
sudo systemctl restart ws281x.service

echo "---- Status"
sudo systemctl status ws281x.service
