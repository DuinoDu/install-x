#!/usr/bin/env bash
# Created by AI

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/stepfun-ai/Step1X-3D.git
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
git reset --hard HEAD
git apply $cur/patch/${name}.patch

python3 -c "import ${name}" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "${name} is already installed, skip"
    exit
fi

# Install PyTorch 2.4.1 as requested
bash $cur/torch.sh 2.4.1

# Install requirements
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi

# Install additional dependencies
pip install torch-cluster -f https://data.pyg.org/whl/torch-2.4.1+cu124.html
pip install "git+https://github.com/facebookresearch/pytorch3d.git@stable"
pip install kaolin==0.17.0 -f https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-2.4.1_cu124.html

# Build texture tools
echo "Building texture tools..."
cd step1x3d_texture/custom_rasterizer
python setup.py install
cd ../differentiable_renderer
python setup.py install
cd ../..

# Download models using huggingface hub
if ! command -v huggingface-cli &> /dev/null; then
    pip install huggingface_hub[cli]
fi

echo "Downloading Step1X-3D models..."
huggingface-cli download stepfun-ai/Step1X-3D --local-dir ./models --local-dir-use-symlinks False


if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'
app:
    python app.py
infer:
    python inference.py
EOF
    $SED -i 's/    /\t/g' Makefile
fi
make app 
