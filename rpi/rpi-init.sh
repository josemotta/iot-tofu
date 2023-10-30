#!/bin/bash

sudo apt update
sudo apt full-upgrade
sudo rpi-update
sudo rpi-eeprom-update -d -a

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker

cat << EOF | sudo tee /home/$USER/compose.yml
version: '3'
services:
  homeassistant:
    container_name: homeassistant
    image: "ghcr.io/home-assistant/home-assistant:stable"
    volumes:
      - .docker/ha/config:/config
      - /etc/localtime:/etc/localtime:ro
    ports:
      - 8123:8123
    restart: unless-stopped
    privileged: true
    network_mode: host
EOF

echo "RPi initialized, please reboot."
