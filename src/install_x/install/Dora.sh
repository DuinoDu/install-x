#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/Seed3D/Dora
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# # If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

bash $cur/torch.sh

$SED -i -e "s/torch==/# torch==/g" requirements.txt
$SED -i -e "s/transformers==/# transformers==/g" requirements.txt
if python3 -c "import transformers" 2>/dev/null; then
    version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  transformers version: $version"
else
    pip3 install transformers==4.40.1
fi

cd pytorch_lightning
pip3 install torch-cluster -f https://data.pyg.org/whl/torch-2.4.0+cu121.html
pip3 install "setuptools>=62.3.0,<75.9"  # required by diso
pip3 install diso 
pip3 install -r requirements.txt 

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'

download-weight:
    python download.py

infer:
    bash test_autoencoder_single_gpu # single gpu
    # bash test_autoencoder_multi_gpu # multi gpu

train:
    bash train_autoencoder_single_node # single node
    # bash test_autoencoder_multi_gpu # multi nodes

EOF
    $SED -i 's/    /\t/g' Makefile
fi

make download-weight
make infer
