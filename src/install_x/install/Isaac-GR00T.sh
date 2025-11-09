#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/NVIDIA/Isaac-GR00T
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

# python3 -c "import ${name}" 2>/dev/null
# if [ $? -eq 0 ]; then
#     echo "${name} is already installed, skip"
#     exit
# fi

# TODO
bash $cur/torch.sh
 
$SED -i -e "s/\"torch==/# \"torch==/g" pyproject.toml
$SED -i -e "s/\"torchvision==/# \"torchvision==/g" pyproject.toml
# $SED -i -e "s/transformers==/# transformers==/g" requirements.txt
# if python3 -c "import transformers" 2>/dev/null; then
#     version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "Unknown")
#     echo "  transformers version: $version"
# else
#     pip3 install transformers==4.40.1
# fi
# pip3 install -r requirements.txt

pip3 install --upgrade setuptools
pip3 install -e .[base]
pip3 install --no-build-isolation flash-attn==2.7.1.post4 

tee -a Makefile <<-'EOF'
infer:
    python scripts/inference_service.py --model-path nvidia/GR00T-N1.5-3B --server

train:
    python scripts/gr00t_finetune.py --dataset-path $(HF_HOME)/lerobot/svla_so101_pickplace \
    --num-gpus 1 --num-steps 10000 --data-config so100_dualcam --video-backend torchvision_av

train-4090:
    python scripts/gr00t_finetune.py --dataset-path $(HF_HOME)/lerobot/svla_so101_pickplace \
    --num-gpus 1 --num-steps 10000 --data-config so100_dualcam --video-backend torchvision_av \
    --no-tune_diffusion_model

EOF
$SED -i 's/    /\t/g' Makefile

make train-4090 
