#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/RoboTwin-Platform/RoboTwin
name=$(basename $url)
name=${name%.git}

prepare_github $url # Challenge-Cup-2025
cd $GITHUB/$name

function setup_env() {
    sudo apt install libvulkan1 mesa-vulkan-drivers vulkan-tools
    bash script/_install.sh
    install_pytorch 2.4.1
    
    echo "${GREEN}>> Download assets${END_COLOR}"
    cd $GITHUB/RoboTwin
    bash script/_download_assets.sh
    
    echo "${GREEN}>> Run example${END_COLOR}"
    cd $GITHUB/RoboTwin
    bash collect_data.sh beat_block_hammer demo_randomizd 0
}


function setup_dp3() {
    cd $GITHUB/RoboTwin
    cd policy/DP3/3D-Diffusion-Policy && pip install -e . && cd ..
    pip3 install zarr==2.12.0 wandb ipdb gpustat dm_control omegaconf hydra-core==1.2.0 dill==0.3.5.1
    pip3 install einops==0.4.1 diffusers==0.11.1 numba==0.56.4 moviepy imageio av matplotlib termcolor
    bash process_data.sh beat_block_hammer demo_randomizd 100
    bash train.sh beat_block_hammer demo_randomizd 100 42 0
}

tee -a Makefile <<-'EOF'

task_name=beat_block_hammer
task_config=demo_randomized
expert_data_num=100
seed=42

generate-data:
    bash collect_data.sh $(task_name) $(task_config) 0

convert-to-zarr:
    cd policy/DP3/3D-Diffusion-Policy; \
    bash collect_data.sh $(task_name) $(task_config) $(expert_data_num) 

train-dp3:
    cd policy/DP3/3D-Diffusion-Policy; \
    bash train.sh $(task_name) $(task_config) $(expert_data_num) $(seed) 0

ckpt_dp3=

eval-dp3:
    cd policy/DP3/3D-Diffusion-Policy; \
    bash eval.sh $(task_name) $(task_config) $(ckpt_dp3) $(expert_data_num) $(seed) 0
EOF
$SED -i 's/    /\t/g' Makefile

setup_env
setup_dp3
