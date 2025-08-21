#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/facebookresearch/vggt
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name
git reset --hard HEAD
git apply $cur/patch/${name}.patch

sed -i -e "s/torch==/#torch==/g" requirements.txt
sed -i -e "s/torchvision==/#torchvision==/g" requirements.txt
bash $cur/torch.sh
pip3 install -r requirements.txt
pip3 install -r requirements_demo.txt

otn-cli --node vggt --repo $GITHUB/$name --unittest True
