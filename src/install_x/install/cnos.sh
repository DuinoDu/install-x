#!/usr/bin/env bash

# Created by AI
_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/nv-nguyen/cnos.git
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

python3 -c "import $name" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "$name is already installed, skip"
    exit
fi

# Install PyTorch using torch.sh
bash $cur/torch.sh 2.4.1

# Convert conda environment.yml to requirements.txt and install dependencies
if [ -f environment.yml ]; then
    echo "Converting conda environment.yml to requirements.txt"
    conda_to_pip environment.yml requirements.txt
    
    # Remove torch and torchvision lines since we use torch.sh
    $SED -i -e "s/torch$/# torch/g" requirements.txt
    $SED -i -e "s/torchvision$/# torchvision/g" requirements.txt
    
    # Install requirements
    pip3 install -r requirements.txt
fi

# Install additional dependencies from README
pip3 install pytorch-lightning==1.8.6
pip3 install opencv-python pycocotools fvcore
pip3 install numpy==1.26.4 omegaconf scipy pandas distinctipy
bash $cur/xformers
# pip3 install xformers==0.0.18

# Install segment-anything (SAM)
pip3 install git+https://github.com/facebookresearch/segment-anything.git

# Install hand tracking toolkit
pip3 install git+https://github.com/facebookresearch/hand_tracking_toolkit.git

# Download model weights (if needed)
if [ ! -f "sam_vit_h_4b8939.pth" ]; then
    echo "Downloading SAM model weights..."
    wget https://dl.fbaipublicfiles.com/segment_anything/sam_vit_h_4b8939.pth
fi

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'
infer:
    python run_inference.py
EOF
    $SED -i 's/    /\t/g' Makefile
fi

make infer
