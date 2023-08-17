#!/bin/bash

npm config set cache /home/node/app/.npm-cache --global

echo 'running .docker/start.sh'
cd /home/node/app
npm install

nodemon -L

# tail -f /dev/null
# npm start