#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/VAST-AI-Research/TripoSR
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

bash $cur/torch.sh

$SED -i -e "s/torch==/# torch==/g" requirements.txt
$SED -i -e "s/transformers==/# transformers==/g" requirements.txt
if python3 -c "import transformers" 2>/dev/null; then
    version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  transformers version: $version"
else
    pip3 install transformers==4.35.0
fi
pip install -r requirements.txt

cd $GITHUB/TripoSR
if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'

example:
    python run.py examples/chair.png --output-dir output/ --bake-texture
app:
    python gradio_app.py --listen
EOF
    $SED -i 's/    /\t/g' Makefile
fi

make example 
make app
