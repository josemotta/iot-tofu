#!/bin/bash

# This folder:
#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)

rm -f /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server

# Generate a pair of ssh keys with no prompts
# https://stackoverflow.com/questions/43235179/how-to-execute-ssh-keygen-without-prompt
ssh-keygen -q -t rsa -N '' <<< $'\ny' >/dev/null 2>&1

# Config locale
cat << EOF >> sudo tee /etc/locale
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
LANGUAGE=en_US.UTF-8
EOF

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
