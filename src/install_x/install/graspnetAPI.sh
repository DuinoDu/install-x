#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/graspnet/graspnetAPI.git
name=$(basename $url)
name=${name%.git}

prepare_github $url
cd $GITHUB/$name

export SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True
pip3 install .

function help() {
    echo ""
}

if [ $? -eq 0 ]; then
    help
fi
