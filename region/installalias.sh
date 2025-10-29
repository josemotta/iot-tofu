# add aliases to default .bashrc
# then run: source .bashrc

cat << EOF >> ~/.bashrc
# some aliases
alias ll='ls -al'

# DOCKER
alias dps='docker ps'
alias dcu='docker compose up'
alias dcud='docker compose up -d'
alias dcd='docker compose down'

# GIT
alias gs='git status --show-stash'
alias gc='git commit -am '

# SENSORS
alias temp='vcgencmd measure_temp'

alias geti2c='sudo raspi-config nonint get_i2c'
alias lsi2c='ls /dev/i2*'
alias deti2c='sudo i2cdetect -y 1'

EOF
