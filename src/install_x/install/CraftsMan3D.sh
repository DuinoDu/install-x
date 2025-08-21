#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/wyysf-98/CraftsMan3D
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

install_pytorch 2.4.1
pip3 install "huggingface_hub[cli]"
pip3 install -r docker/requirements.txt
# $SED -i -e "s/torch==/# torch==/g" requirements.txt
# $SED -i -e "s/transformers==/# transformers==/g" requirements.txt
# if python3 -c "import transformers" 2>/dev/null; then
#     version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "Unknown")
#     echo "  transformers version: $version"
# else
#     pip3 install transformers==4.40.1
# fi
# pip3 install -r requirements.txt

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'

download-weight:
    huggingface-cli download craftsman3d/craftsman --local-dir ./ckpts/craftsman

example:
    python inference.py --input eval_data --device 0 --model ./ckpts/craftsman

app:
    python gradio_app.py --model_path ./ckpts/craftsman

# training the shape-autoencoder
train1:
    python train.py --config ./configs/shape-autoencoder/michelangelo-l768-e64-ne8-nd16.yaml \
        --train --gpu 0

# training the image-to-shape diffusion model
train2:
    python train.py --config .configs/image-to-shape-diffusion/clip-dino-rgb-pixart-lr2e4-ddim.yaml \
        --train --gpu 0

EOF
    $SED -i 's/    /\t/g' Makefile
fi

make download-weight
make app
