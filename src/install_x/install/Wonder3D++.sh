#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/xxlong0/Wonder3D
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10 Wonder3D_Plus
cd $GITHUB/$name

bash $cur/torch.sh

$SED -i -e "s/torch==/# torch==/g" requirements.txt
$SED -i -e "s/transformers==/# transformers==/g" requirements.txt
if python3 -c "import transformers" 2>/dev/null; then
    version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  transformers version: $version"
else
    pip3 install transformers==4.40.1
fi
$SED -i -e "s%git+https://github.com/facebookresearch/pytorch3d%# git+https://github.com/facebookresearch/pytorch3d%g" requirements.txt
if python3 -c "import pytorch3d" 2>/dev/null; then
    version=$(python3 -c "import pytorch3d; print(pytorch3d.__version__)" 2>/dev/null || echo "Unknown")
    echo "  pytorch3d version: $version"
else
    pip3 install git+https://github.com/facebookresearch/pytorch3d.git@stable
fi
pip install -r requirements.txt
pip install torch_scatter


if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'

download-weights:
    python -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='flamehaze1115/Wonder3D_plus', local_dir='./ckpts')"

infer:
    python run.py --input_path example_images/owl.png \
        --camera_type ortho \
        --output_path outputs 
EOF
    $SED -i 's/    /\t/g' Makefile
fi

make download-weights
make infer
