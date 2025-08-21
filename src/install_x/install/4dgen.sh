#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/lzylucy/4dgen
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

bash $cur/torch.sh
pip3 install pytorch3d
pip3 install -r requirements/pt2.txt
conda_to_pip environment.yml requirements.txt
pip install -r requirements.txt
pip install accelerate==0.22.0

tee -a Makefile <<-'EOF'

data:
    wget-web https://real.stanford.edu/4dgen/

finetune-vae:
    CUDA_VISIBLE_DEVICES="0,1,2,3" HYDRA_FULL_ERROR=1 python3 scripts/train.py --config-name=finetune_autoencoder_workspace

train:
    CUDA_VISIBLE_DEVICES="0,1,2,3" HYDRA_FULL_ERROR=1 python scripts/train.py --config-name=finetune_svd_lightning_workspace

infer:
    python notebooks/eval.py

EOF
$SED -i 's/    /\t/g' Makefile
