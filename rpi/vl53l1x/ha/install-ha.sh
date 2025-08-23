#!/bin/bash

#Add Homeassistant configuration for VL53L1X Time-of-Flight (ToF) laser-ranging sensor.
#
#Based on rpi/rpi-init.sh that creates Docker compose.yml below to launch Homeassistant container
#
#services:
#  homeassistant:
#    container_name: homeassistant
#    image: "ghcr.io/home-assistant/home-assistant:stable"
#    volumes:
#      - .docker/ha/config:/config
#      - /etc/localtime:/etc/localtime:ro
#    ports:
#      - 8123:8123
#    restart: unless-stopped
#    privileged: true
#    network_mode: host
#

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

cp --remove-destination configuration.yaml ~/.docker/ha/config
echo "Added rest configuration for vl53l1x distance sensor"

echo "---- Status"
ls -l ~/.docker/ha/config
