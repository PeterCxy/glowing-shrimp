#!/bin/bash

if [[ -e './dist' ]]; then
  rm -rf ./dist
fi

mkdir -p ./dist

# Copy needed styles
mkdir -p ./dist/node_modules/dialog-polyfill
cp ./node_modules/dialog-polyfill/dialog-polyfill.css ./dist/node_modules/dialog-polyfill/
cp -R ./styles ./dist/styles

# Build
./node_modules/.bin/browserify . -o bundle.js
cp bundle.js ./dist/

# Copy the main HTML
cp index.html ./dist/