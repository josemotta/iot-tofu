#!/bin/bash

# Add Homeassistant configuration for VL53L1X Time-of-Flight (ToF) laser-ranging distance sensor.
# Based on the Docker compose below, generated at rpi/rpi-init.sh to create the Homeassistant container.
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

if [ ! -d /home/$USER/.docker/ha/config/configuration.yaml ]; then
    echo "Missing expected Homeassistant configuration at ./docker/ha/config"
    exit
fi

cat << EOF | tee -a /home/$USER/.docker/ha/config/configuration.yaml

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

echo "Appended homeassistant configuration for vl53l1x distance sensor"

echo "The directory & configuration file are shown below:"
ls -l /home/$USER/.docker/ha/config/
cat /home/$USER/.docker/ha/config/configuration.yaml
