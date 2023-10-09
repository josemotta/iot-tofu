#!/bin/bash
while true; do eval "$(cat /home/jo/pipe/pipe)" &> /home/jo/pipe/pipe.txt; done
#while true; do eval "$(cat /home/$USER/pipe/pipe)" &> /home/$USER/pipe/pipe.txt; done
