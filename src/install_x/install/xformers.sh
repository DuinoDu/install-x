#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/facebookresearch/xformers
name=$(basename $url)
name=${name%.git}

python3 -c "import ${name}" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "${name} is already installed, skip"
    exit
fi

prepare_github $url
cd $GITHUB/$name

bash $cur/torch.sh

# version with torch
#   v0.0.29 ~ 2.4
#   v0.0.30 ~ 2.7
git checkout v0.0.29
git submodule update --init --recursive

export TORCH_CUDA_ARCH_LIST="6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6 8.9"
pip3 install .

function help() {
    echo "${RED}Or you can instal from pre-built:"
    echo "https://download.pytorch.org/whl/xformers"
    echo ">> pip3 install xformers==0.0.30 --index-url https://download.pytorch.org/whl/cu128${END_COLOR}"
}

if [ $? -eq 0 ]; then
    help
fi
