#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/traveller59/spconv
name=$(basename $url)
name=${name%.git}

python3 -c "import ${name}" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "${name} is already installed, skip"
    exit
fi

prepare_github $url
cd $GITHUB/$name

git reset --hard HEAD
git apply $cur/patch/${name}.patch

prepare_github https://github.com/FindDefinition/cumm
cd $GITHUB/cumm
pip3 install .

cd $GITHUB/spconv
pip3 install -e .

python3 -c "import spconv"

function help() {
    echo ""
}

if [ $? -eq 0 ]; then
    help
fi
