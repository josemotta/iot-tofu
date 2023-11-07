#!/bin/bash

raspi-config do_change_locale en_US.UTF-8 nonint

rm -f /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server

# Generate a pair of ssh keys with no prompts
# https://stackoverflow.com/questions/43235179/how-to-execute-ssh-keygen-without-prompt
ssh-keygen -q -t rsa -N '' <<< $'\ny' >/dev/null 2>&1

# add aliases to default .bashrc
cat << EOF >> /etc/skel/.bashrc

# some more aliases
alias ll='ls -al'

alias dps='docker ps'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'

alias gs='git status --show-stash'
alias gc='git commit -am '

alias temp='vcgencmd measure_temp'
EOF
