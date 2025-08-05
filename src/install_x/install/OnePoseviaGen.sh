#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/GZWSAMA/OnePoseviaGen/
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.11
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

python3 -c "import ${name}" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "${name} is already installed, skip"
    exit
fi

bash $cur/torch.sh 2.4.1
chmod +x setup.sh
./setup.sh


function help() {
    echo ""
}

if [ $? -eq 0 ]; then
    help
fi
