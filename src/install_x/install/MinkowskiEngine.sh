#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

prepare_github https://github.com/NVIDIA/MinkowskiEngine.git 
cd $GITHUB/MinkowskiEngine

git reset --hard HEAD
git apply $cur/patch/MinkowskiEngine.patch

sudo apt install -y build-essential libopenblas-dev # python3-dev 
pip3 install ninja
bash $cur/torch.sh

python3 -c "import MinkowskiEngine" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "MinkowskiEngine is already installed, skip"
    exit
fi

export TORCH_CUDA_ARCH_LIST="6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6 8.9"
export TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
python3 setup.py install --blas=openblas

function help() {
    echo "If you meet error message: "
    echo "error: more than one instance of overloaded function "std::__to_address" matches the argument list:"
    echo ""
    echo "Fix it by https://github.com/NVIDIA/MinkowskiEngine/issues/596."
}

if [ $? -eq 0 ]; then
    help
fi
