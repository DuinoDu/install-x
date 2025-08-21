#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/OpenGVLab/DCNv4
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10

pip3 uninstall mmcv-lite > /dev/null 2>&1
bash $cur/mmcv.sh v1.5.0
pip3 install mmsegmentation==0.27.0
pip3 install timm==0.6.11 mmdet==2.28.1

# build DCNv3
cd $GITHUB/$name/segmentation/ops_dcnv3
bash ./make.sh
python3 test.py

# build DCNv4
cd $GITHUB/$name/DCNv4_op
bash ./make.sh
python3 test.py

cd $GITHUB/$name/segmentation
wget https://huggingface.co/OpenGVLab/DCNv4/resolve/main/upernet_flash_internimage_l_640_160k_ade20k.pth

otn-cli --node internimage_semseg --repo $GITHUB/$name --unittest True

# # train
# cd $GITHUB/$name/segmentation
# if [ ! -d data ];then
#     mkdir -p data
# fi
# ln -s ${HOME}/data/ade20k/ADEChallengeData2016 data/ADEChallengeData2016
# CUDA_VISIBLE_DEVICES=0 python3 train.py configs/ade20k/upernet_flash_internimage_t_512_160k_ade20k.py
