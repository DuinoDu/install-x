#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/taeyeopl/Any6D
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

bash $cur/torch.sh
python -m pip install -r requirements.txt

# Install NVDiffRast
python -m pip install --quiet --no-cache-dir git+https://github.com/NVlabs/nvdiffrast.git
# Kaolin
python -m pip install --no-cache-dir kaolin==0.16.0 -f https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-2.4.0_cu121.html
# PyTorch3D
pip install --extra-index-url https://miropsota.github.io/torch_packages_builder pytorch3d==0.7.8+pt2.4.1cu121
# Build extensions
CMAKE_PREFIX_PATH=$VIRTUAL_ENV/lib/python3.10/site-packages/pybind11/share/cmake/pybind11 bash foundationpose/build_all_conda.sh

# build SAM2
cd sam2 && pip install -e . &&  cd ..

# build InstantMesh
cd instantmesh && pip install -r requirements.txt
git clone https://huggingface.co/TencentARC/InstantMesh ckpts
cd ..

# build bop_toolkit
cd bop_toolkit && python setup.py install && cd ..

pip3 install huggingface-hub==0.25.2
pip3 install accelerate==0.31.0
