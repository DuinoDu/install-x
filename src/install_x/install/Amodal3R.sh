#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/Sm0kyWu/Amodal3R
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name
bash $cur/torch.sh

. ./setup.sh --basic --xformers --flash-attn --diffoctreerast --spconv --mipgaussian --kaolin --nvdiffrast
. ./setup.sh --demo

if python3 -c "import kaolin" 2>/dev/null; then
    version=$(python3 -c "import kaolin; print(kaolin.__version__)" 2>/dev/null || echo "Unknown")
    echo "  kaolin version: $version"
else
    pip3 install kaolin -f https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-2.4.0_cu121.html
fi

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'

infer:
    python ./inference.py
EOF
    $SED -i 's/    /\t/g' Makefile
fi
ln -s example input
make infer 
