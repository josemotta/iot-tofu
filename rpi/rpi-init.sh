#!/bin/bash

# Choose wisely, 'docker install' already gets the latest update.
# sudo apt update
# sudo apt full-upgrade
# sudo rpi-update
# sudo rpi-eeprom-update -d -a

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo chmod +x get-docker.sh
# keys Y N
sudo sh get-docker.sh <<< $'Y\nN\n'
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker

# Docker compose for RPi with homeassistant
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
