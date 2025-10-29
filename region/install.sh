#!/bin/bash

# Choose wisely the necessary updates!

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Docker install below starts with an update.
#sudo apt update
#sudo apt full-upgrade

# Clear docker folder
#if [ -d /var/lib/docker ]; then
#  sudo rm -rf /var/lib/docker
#fi

# Install Docker
#curl -fsSL https://get.docker.com -o get-docker.sh
#sudo chmod +x get-docker.sh
#sudo sh get-docker.sh
#sudo groupadd docker
#sudo usermod -aG docker $USER
#sudo systemctl enable docker

# Docker compose for RPi with homeassistant
cat << EOF | tee ~/compose.yml
services:
  homeassistant:
    container_name: homeassistant
    image: "ghcr.io/home-assistant/home-assistant:stable"
    volumes:
      - .docker/ha/config:/config
      - /etc/localtime:/etc/localtime:ro
      - /sys/class/thermal/cooling_device0/subsystem/thermal_zone0/temp:/thermal/thermal_zone0/temp
    ports:
      - 8123:8123
    restart: unless-stopped
    privileged: true
    network_mode: host
EOF

if [ ! -d /home/$USER/.docker/ha/config/ ]; then
    echo "Missing expected Homeassistant configuration at ./docker/ha/config"
    exit
fi

cp ./configuration.yaml /home/$USER/.docker/ha/config/configuration.yaml
cp ./secrets.yaml /home/$USER/.docker/ha/config/secrets.yaml
cp ./sensors.yaml /home/$USER/.docker/ha/config/sensors.yaml

echo "Added TOFU Homeassistant configuration."

echo "The directory & configuration files are shown below:"

ls -l /home/$USER/.docker/ha/config/
#cat /home/$USER/.docker/ha/config/configuration.yaml
#cat /home/$USER/.docker/ha/config/sensors.yaml

echo "TOFU Homeassistant initialized, please reboot."
