#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/naver/dust3r
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

sed -i -e "s/torch==/#torch==/g" requirements.txt
sed -i -e "s/torchvision==/#torchvision==/g" requirements.txt
bash $cur/torch.sh
pip3 install -r requirements.txt
pip3 install -r requirements_optional.txt

cd croco/models/curope/
python setup.py build_ext --inplace
cd ../../../

mkdir -p checkpoints/
wget https://download.europe.naverlabs.com/ComputerVision/DUSt3R/DUSt3R_ViTLarge_BaseDecoder_512_dpt.pth -P checkpoints/

python3 demo.py --model_name DUSt3R_ViTLarge_BaseDecoder_512_dpt --local_network
