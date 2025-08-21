#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/facebookresearch/co-tracker
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10

if python3 -c "import cotracker" 2>/dev/null; then
    echo "${name} is already installed, skip"
    exit
fi

cd $GITHUB/$name
pip3 install -e .
pip3 install matplotlib flow_vis tqdm tensorboard

mkdir -p checkpoints
cd checkpoints
# download the online (multi window) model
wget https://huggingface.co/facebook/cotracker3/resolve/main/scaled_online.pth
# download the offline (single window) model
wget https://huggingface.co/facebook/cotracker3/resolve/main/scaled_offline.pth
cd ..
