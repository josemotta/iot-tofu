#!/bin/bash

raspi-config do_change_locale en_US.UTF-8 do_i2c 0 nonint

rm -f /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server

# Generate a pair of ssh keys with no prompts
# https://stackoverflow.com/questions/43235179/how-to-execute-ssh-keygen-without-prompt
ssh-keygen -q -t rsa -N '' <<< $'\ny' >/dev/null 2>&1
