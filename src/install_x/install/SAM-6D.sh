#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/_utils.sh

url="https://github.com/JiehongLin/SAM-6D"
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name
git reset --hard HEAD
git apply ${cur}/patch/SAM-6D.patch

install_pytorch 2.4.1

cd SAM-6D
conda_to_pip environment.yaml requirements.txt
sed -i -e "s/torch==/#torch==/g" requirements.txt
sed -i -e "s/torchvision==/#torchvision==/g" requirements.txt
sed -i -e "s/pytorch-lightning==1.8.1/pytorch-lightning==1.9.1/g" requirements.txt
pip3 install -r requirements.txt
pip3 install ruamel_yaml

### Install pointnet2
cd Pose_Estimation_Model/model/pointnet2
python setup.py install
cd ../../../

# Download weights
cd $GITHUB/$name/SAM-6D/Instance_Segmentation_Model
if [ ! -f checkpoints/segment-anything/sam_vit_h_4b8939.pth ];then
    python download_sam.py
fi

if [ ! -f checkpoints/FastSAM/FastSAM-x.pt ];then
    mkdir -p checkpoints/FastSAM
    wget https://github.com/ultralytics/assets/releases/download/v8.3.0/FastSAM-x.pt -o checkpoints/FastSAM/FastSAM-x.pt
fi
if [ ! -f checkpoints/dinov2/dinov2_vitl14_pretrain.pth ];then
    python download_dinov2.py
fi

# Download blender-3.3.1 for blenderproc==2.6.1
bash $cur/blender.sh 3.3.1

# Create Makefile
cd $GITHUB/$name/SAM-6D
tee -a Makefile <<-'EOF'
download:
    cd Pose_Estimation_Model; python download_sam6d-pem.py
    echo "https://drive.google.com/file/d/1joW9IvwsaRJYxoUmGo68dBVg-HcFNyI7/view?pli=1"

CAD_PATH=$(PWD)/Data/Example/obj_000005.ply    # path to a given cad model(mm)
RGB_PATH=$(PWD)/Data/Example/rgb.png           # path to a given RGB image
DEPTH_PATH=$(PWD)/Data/Example/depth.png       # path to a given depth map(mm)
CAMERA_PATH=$(PWD)/Data/Example/camera.json    # path to given camera intrinsics
OUTPUT_DIR=$(PWD)/Data/Example/outputs         # path to a pre-defined file for saving results

infer:
	export CAD_PATH=$(CAD_PATH); \
	export RGB_PATH=$(RGB_PATH); \
	export DEPTH_PATH=$(DEPTH_PATH); \
	export CAMERA_PATH=$(CAMERA_PATH); \
	export OUTPUT_DIR=$(OUTPUT_DIR); \
	bash -ex demo.sh
EOF
$SED -i 's/    /\t/g' Makefile
