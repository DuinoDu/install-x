#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/Dao-AILab/flash-attention
name=$(basename $url)
name=${name%.git}

prepare_github $url
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

# v2.8.2 have bug for undefined symbol
git checkout v2.5.9.post1

python3 -c "import flash_attn" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "${name} is already installed, skip"
    exit
fi

pip3 install . --no-build-isolation

# pip3 install https://github.com/Dao-AILab/flash-attention/releases/download/v2.8.2/flash_attn-2.8.2+cu12torch2.6cxx11abiTRUE-cp310-cp310-linux_x86_64.whl
