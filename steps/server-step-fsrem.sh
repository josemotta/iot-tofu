#!/bin/bash

if [ $1 == "" ]; then
  echo Missing client id
  exit 1
fi
export CLIENT_ID=$1

# Remove fs from $CLIENT_ID
sudo rm -r /nfs/$CLIENT_ID
