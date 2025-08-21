#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/microsoft/TRELLIS
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name
bash $cur/torch.sh

. ./setup.sh --basic --xformers --flash-attn --diffoctreerast --spconv --mipgaussian --kaolin --nvdiffrast
. ./setup.sh --demo
pip3 install kaolin -f https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-2.4.0_cu121.html

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'

example:
    python example.py

app:
    python app.py
EOF
    $SED -i 's/    /\t/g' Makefile
fi
make app 
