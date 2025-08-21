#!/usr/bin/env bash
# Created by AI

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/3DTopia/3DTopia-XL
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

bash $cur/torch.sh 2.4.1
$SED -i -e "s/torch==/# torch==/g" requirements.txt
$SED -i -e "s/pymeshlab==/pymeshlab#==/g" requirements.txt

$SED -i -e "s/transformers==/# transformers==/g" requirements.txt
if python3 -c "import transformers" 2>/dev/null; then
    version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  transformers version: $version"
else
    pip3 install transformers==4.40.1
fi
$SED -i -e "s/diffusers==/# diffusers==/g" requirements.txt
if python3 -c "import diffusers" 2>/dev/null; then
    version=$(python3 -c "import diffusers; print(diffusers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  diffusers version: $version"
else
    pip3 install diffusers==0.19.3
fi
$SED -i -e "s/triton==/# triton==/g" requirements.txt
if python3 -c "import triton" 2>/dev/null; then
    version=$(python3 -c "import triton; print(triton.__version__)" 2>/dev/null || echo "Unknown")
    echo "  triton version: $version"
else
    pip3 install triton==2.1.0
fi
pip3 install -r requirements.txt

export EIGEN_INCLUDE_DIR=/usr/include/eigen3

# bash install.sh
CURRENT=$(pwd)
cd dva/mvp/extensions/mvpraymarch
make -j4
cd ../utils
make -j4
cd ${CURRENT}
pip install ./simple-knn
if [ ! -d cubvh ];then
    git clone https://github.com/ashawkey/cubvh --recursive
fi
cd cubvh
pip install .
cd ${CURRENT}


# Download pretrained weights
if [ ! -d pretrained ];then
    mkdir -p pretrained
fi
cd pretrained

# Download DiT model
if [ ! -f "model_sview_dit_fp16.pt" ]; then
    wget https://huggingface.co/FrozenBurning/3DTopia-XL/resolve/main/model_sview_dit_fp16.pt
fi

# Download VAE model
if [ ! -f "model_vae_fp16.pt" ]; then
    wget https://huggingface.co/FrozenBurning/3DTopia-XL/resolve/main/model_vae_fp16.pt
fi

# Download CLIP model for text conditioning
if [ ! -f "open_clip_pytorch_model.bin" ]; then
    wget "https://huggingface.co/laion/CLIP-ViT-L-14-DataComp.XL-s13B-b90K/resolve/main/open_clip_pytorch_model.bin?download=true" -O open_clip_pytorch_model.bin
fi

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'
app:
    python app.py

infer:
    python inference.py ./configs/inference_dit.yml

infer-text:
    python inference.py ./configs/inference_dit_text.yml
EOF
    $SED -i 's/    /\t/g' Makefile
fi
make app 
