#!/usr/bin/env bash
# Created by AI

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/VAST-AI-Research/TripoSG.git
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

python3 -c "import ${name}" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "${name} is already installed, skip"
    exit
fi

# Install PyTorch
bash $cur/torch.sh

# Check if transformers is already installed
if python3 -c "import transformers" 2>/dev/null; then
    version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  transformers version: $version"
else
    pip3 install transformers==4.40.1
fi

# Install requirements
pip3 install -r requirements.txt

# Create pretrained_weights directory for model downloads
mkdir -p pretrained_weights

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'
infer:
    python -m scripts.inference_triposg --image-input assets/example_data/hjswed.png --output-path ./output.glb

infer-scribble:
    python -m scripts.inference_triposg_scribble --image-input assets/example_scribble_data/cat_with_wings.png --prompt \"a cat with wings\" --output-path output.glb"
EOF
    $SED -i 's/    /\t/g' Makefile
fi
make infer 
