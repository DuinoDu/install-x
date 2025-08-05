#!/usr/bin/env bash

set -e
_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/QwenLM/Qwen2.5-VL
name=$(basename $url)
name=${name%.git}
prepare_github $url 3.10
cd $GITHUB/$name

bash $cur/torch.sh

# pip3 install torch==2.5.0 torchvision==0.20.0 torchaudio==2.5.0 --index-url https://download.pytorch.org/whl/cu121

if python3 -c "import transformers" 2>/dev/null; then
    version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "未知")
    echo "  transformers version: $version"
else
    pip3 install git+https://github.com/huggingface/transformers accelerate
fi

pip3 install "qwen-vl-utils[decord]"
pip3 install flash-attn # torch >= 2.2

otn-cli --node qwen2_5_vl --unittest True
