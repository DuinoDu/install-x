#!/usr/bin/env bash
# Created by AI

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/facebookresearch/foundpose.git
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
git reset --hard HEAD
git apply $cur/patch/${name}.patch

# Install PyTorch 2.4.1 (instead of conda pytorch)
bash $cur/torch.sh

pip3 install git+https://github.com/facebookresearch/hand_tracking_toolkit
pip3 install PyOpenGL-accelerate

# Create Makefile for testing
if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'
download:
    wget https://huggingface.co/datasets/evinpinar/foundpose/resolve/main/templates.zip
    wget wget https://huggingface.co/datasets/evinpinar/foundpose/resolve/main/object_repre.zip
    wget https://bop.felk.cvut.cz/media/data/bop_datasets_extra/bop23_default_detections_for_task4.zip

demo:
    export BOP_PATH=`pwd`/bop_datasets && \
    export PYTHONPATH=./:./external/bop_toolkit:./external/dinov2 && \
    python scripts/infer.py --opts-path configs/infer/lmo.json \

EOF
    $SED -i 's/    /\t/g' Makefile
fi

make download
make demo
