#!/usr/bin/env bash

set -e

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/luca-medeiros/lang-segment-anything
name=$(basename $url)
name=${name%.git}
prepare_github $url
cd $GITHUB/$name

git reset --hard e9af744d
git apply $cur/patch/lang-segment-anything_e9af744d.patch

bash $cur/torch.sh
pip3 install -r requirements.txt

pip3 install -e .

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'

start-gradio:
    python3 app.py
EOF
    $SED -i 's/    /\t/g' Makefile
fi

make start-gradio 
