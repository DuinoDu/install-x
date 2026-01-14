#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

cd $GITHUB
git clone https://github.com/Coding-Solo/godot-mcp.git
cd godot-mcp 
npm install
npm run build

echo ">> node $GITHUB/godot-mcp/build/index.js"
