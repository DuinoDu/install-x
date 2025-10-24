#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/open-mmlab/mmcv.git
name=$(basename $url)
name=${name%.git}

python3 -c "import ${name}" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "${name} is already installed, skip"
    exit
fi

MMCV_VERSION=v1.5.0
if [ -n "$1" ];then
    MMCV_VERSION=$1
fi

prepare_github $url 
cd $GITHUB/$name

bash $cur/torch.sh

git checkout $MMCV_VERSION
git submodule update --init --recursive
git apply $cur/patch/mmcv_v1.5.0.patch

set -e
export MMCV_WITH_CUDA=1
export MMCV_WITH_OPS=1
python3 setup.py install

pip3 install yapf==0.40.1
