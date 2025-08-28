#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/TencentARC/InstantMesh
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

# bash $cur/torch.sh

$SED -i -e "s/torch==/# torch==/g" requirements.txt
$SED -i -e "s/transformers==/# transformers==/g" requirements.txt
$SED -i -e "s/diffusers==/# diffusers==/g" requirements.txt
if python3 -c "import transformers" 2>/dev/null; then
    version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  transformers version: $version"
else
    pip3 install transformers==4.34.1
fi
if python3 -c "import diffusers" 2>/dev/null; then
    version=$(python3 -c "import diffusers; print(diffusers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  diffusers version: $version"
else
    pip3 install diffusers==0.20.2
fi
pip3 install -r requirements.txt


if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'
infer:
    python run.py configs/instant-mesh-large.yaml examples/hatsune_miku.png --save_video
app:
    python app.py
EOF
    $SED -i 's/    /\t/g' Makefile
fi
make app
