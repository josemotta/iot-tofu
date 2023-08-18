#!/bin/bash

cd /home/node/app
npm install
npm run build

nodemon -L

# tail -f /dev/null
# npm start