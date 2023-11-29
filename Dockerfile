# Check out https://hub.docker.com/_/node to select a new base image
FROM node:20.5-bullseye-slim

VOLUME /hostpipe

RUN apt update && apt install -y \
    git \
    curl \
    bash

RUN npm install -g @loopback/cli npm@9.8.1
RUN touch /root/.bashrc | echo "PS1='\w\$ '" >> /root/.bashrc

# Set to a non-root built-in user `node`
USER node

RUN mkdir -p /home/node/app
RUN mkdir -p /home/node/app/region

WORKDIR /home/node/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY --chown=node package*.json ./

RUN npm install
# TODO: test production install
# RUN npm ci --only=prod

# Bundle app source code
COPY --chown=node . .

RUN npm run build

# Bind to all network interfaces so that it can be mapped to the host OS
ENV HOST=0.0.0.0 PORT=3000

EXPOSE ${PORT}
CMD [ "node", "." ]
