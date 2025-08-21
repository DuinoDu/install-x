#!/usr/bin/env bash

set -e

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/Tencent-Hunyuan/Hunyuan3D-2.1
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

if [[ -v "$VIRTUAL_ENV" ]];then
    echo "Only support running in venv."
    exit
else
    echo "python venv: $VIRTUAL_ENV"
fi

bash $cur/torch.sh 2.4.1

$SED -i -e "s/transformers==/# transformers==/g" file
if python3 -c "import transformers" 2>/dev/null; then
    version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  transformers version: $version"
else
    pip3 install transformers==4.46.0
fi
pip3 install -r requirements.txt

cd hy3dpaint/custom_rasterizer
pip3 install -e .
cd ../..
cd hy3dpaint/DifferentiableRenderer
bash compile_mesh_painter.sh
cd ../..

cd $GITHUB/$name

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'

download-weight:
    wget https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth -P hy3dpaint/ckpt

app:
    python3 gradio_app.py \
    --model_path tencent/Hunyuan3D-2.1 \
    --subfolder hunyuan3d-dit-v2-1 \
    --texgen_model_path tencent/Hunyuan3D-2.1 \
    --low_vram_mode
EOF
    $SED -i 's/    /\t/g' Makefile
fi

make download-weight
make app
