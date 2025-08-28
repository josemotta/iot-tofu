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

echo "---- Requirements"
if [ ! -d /home/$USER/.docker/ha/config/configuration.yaml ]; then
    echo "Missing original Homeassistant configuration file"
    exit
fi


echo -n "hello" >> <filename>

cat << EOF | sudo tee /etc/exports
rest:
  resource: 'http://127.0.0.1:5000/test'
  scan_interval: 2
  sensor:
    - name: 'distance'
      value_template: '{{ value_json['distance'] | round(1) }}'
      device_class: distance
      unit_of_measurement: 'mm'
    - name: 'chip'
      value_template: '{{ value_json['chip'] }}'
      device_class: specs
    - name: 'version'
      value_template: '{{ value_json['version'] }}'
      device_class: specs
EOF

echo "---- Configuration"
cp --remove-destination configuration.yaml /home/$USER/.docker/ha/config
echo "Added rest configuration for vl53l1x distance sensor"

echo "---- Status"
ls -l ~/.docker/ha/config
