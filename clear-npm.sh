#!/bin/sh
rm -rf dist
rm -rf node_modules
rm package-lock.json
rm tsconfig.tsbuildinfo
rm -rf .npm-cache
npm i
