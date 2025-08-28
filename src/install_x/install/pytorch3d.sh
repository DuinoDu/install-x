#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/facebookresearch/pytorch3d.git
name=$(basename $url)
name=${name%.git}

python3 -c "import ${name}" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "${name} is already installed, skip"
    exit
fi

prepare_github $url
cd $GITHUB/$name

bash $cur/torch.sh
export TORCH_CUDA_ARCH_LIST="6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6 8.9"
pip3 install .
