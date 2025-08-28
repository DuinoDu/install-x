#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/Stable-X/Stable3DGen
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name
bash $cur/torch.sh
bash $cur/spconv.sh
bash $cur/xformers.sh

pre_install_reqquirement_if_need transformers 4.46.3
pre_install_reqquirement_if_need diffusers 0.28.0
pre_install_reqquirement_if_need numpy 1.26.4
pre_install_reqquirement_if_need kornia 0.8.0
pre_install_reqquirement_if_need timm 0.6.7

pip install -r requirements.txt

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'
app:
    python app.py
EOF
    $SED -i 's/    /\t/g' Makefile
fi
make app 
