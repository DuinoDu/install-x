#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/DepthAnything/Video-Depth-Anything
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name
git reset --hard HEAD
git apply $cur/patch/${name}.patch

# sed -i -e "s/torch==/#torch==/g" requirements.txt
# sed -i -e "s/torchvision==/#torchvision==/g" requirements.txt
# sed -i -e "s/xformers==/#xformers==/g" requirements.txt

bash $cur/torch.sh
bash $cur/xformers.sh

pip3 install -r requirements.txt

bash get_weights.sh
cd checkpoints
wget https://huggingface.co/depth-anything/Metric-Video-Depth-Anything-Large/resolve/main/metric_video_depth_anything_vitl.pth
cd ../metric_depth; ln -s ../checkpoints checkpoints 
cd ..

otn-cli --node depth-anything-video  --repo $GITHUB/$name --unittest True
