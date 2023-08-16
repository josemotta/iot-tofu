#!/bin/sh

echo 'running .docker/start.sh'
cd /home/node/app
npm install

tail -f /dev/null

# Expected to run at dev console
#npm run start