#!/bin/bash

# Choose wisely the necessary updates!
# Docker install below starts with an update.
sudo apt update
sudo apt full-upgrade
sudo rpi-update
# sudo rpi-eeprom-update -d -a

# Clear docker folder
if [ -d /var/lib/docker ]; then
  sudo rm -r /var/lib/docker/*
fi

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo chmod +x get-docker.sh
sudo sh get-docker.sh
#sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker

# Docker compose for RPi with homeassistant
cat << EOF | tee ~/compose.yml
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

# add aliases to default .bashrc
cat << EOF >> ~/.bashrc
# some aliases
alias ll='ls -al'

alias dps='docker ps'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'

# alias gs='git status --show-stash'
# alias gc='git commit -am '

alias temp='vcgencmd measure_temp'
EOF

echo "RPi initialized, please reboot."
