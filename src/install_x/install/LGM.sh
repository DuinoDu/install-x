#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/3DTopia/LGM
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

bash $cur/torch.sh
bash $cur/xformers.sh

# a modified gaussian splatting (+ depth, alpha rendering)
git clone --recursive https://github.com/ashawkey/diff-gaussian-rasterization
pip install ./diff-gaussian-rasterization

# for mesh extraction
pip install git+https://github.com/NVlabs/nvdiffrast

pip install -r requirements.txt

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'

download-weight:
    mkdir pretrained && cd pretrained && \
    wget https://huggingface.co/ashawkey/LGM/resolve/main/model_fp16_fixrot.safetensors

app:
    python app.py big --resume pretrained/model_fp16_fixrot.safetensors
EOF
    $SED -i 's/    /\t/g' Makefile
fi

make download-weight
make app
