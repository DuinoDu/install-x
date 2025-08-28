#!/usr/bin/env bash
# Created by AI

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/vlongle/pixie.git
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# Install PyTorch with specified version
bash $cur/torch.sh 2.4.1

# Install core dependencies
pip3 install ninja
pip3 install git+https://github.com/NVlabs/tiny-cuda-nn/#subdirectory=bindings/torch

# Install third-party dependencies
pip3 install -e third_party/nerfstudio
pip3 install -e third_party/f3rm
pip3 install -v "git+https://github.com/facebookresearch/pytorch3d.git@stable"
pip3 install viser==0.2.7
pip3 install tyro==0.6.6

# Install Gaussian splatting dependencies
pip3 install -v -e third_party/PhysGaussian/gaussian-splatting/submodules/simple-knn/
pip3 install -v -e third_party/PhysGaussian/gaussian-splatting/submodules/diff-gaussian-rasterization/

# Install additional dependencies
pip3 install -e third_party/vlmx
MAX_JOBS=16 pip3 install -v -U flash-attn --no-build-isolation

# Install setup.py dependencies
pip3 install objaverse sentence-transformers PyMCubes==0.1.4 hydra-core omegaconf trimesh plyfile matplotlib numpy==1.24.4 params-proto python-slugify warp_lang==0.10.1 taichi==1.5.0 dotenv timm==1.1.13 qwen-vl-utils[decord] accelerate transformers streamlit huggingface_hub colorlog seaborn umap-learn

# Install the main package
pip3 install -e .

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'
download-data:
    python scripts/download_data.py
infer:
    python pipeline.py obj_id=f420ea9edb914e1b9b7adebbacecc7d8 material_mode=neural
render:
    python render.py obj_id=f420ea9edb914e1b9b7adebbacecc7d8
EOF
    $SED -i 's/    /\t/g' Makefile
fi

# Test the installation
echo "Testing installation..."
python -c "import pixie; print('Pixie imported successfully')"

# Download model data
echo "Downloading model data..."
make download-data

# Run a simple demo to verify installation
echo "Running demo..."
make infer
