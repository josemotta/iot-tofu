#!/bin/sh
rm -rf dist
rm -rf node_modules
rm -rf .npm-cache
rm -rf __coverage
rm package-lock.json
rm tsconfig.tsbuildinfo
npm i
