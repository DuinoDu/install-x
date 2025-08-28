#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/Stable-X/StableNormal
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

# python3 -c "import ${name}" 2>/dev/null
# if [ $? -eq 0 ]; then
#     echo "${name} is already installed, skip"
#     exit
# fi

bash $cur/torch.sh

$SED -i -e "s/torch==/# torch==/g" requirements.txt
$SED -i -e "s/torch==/# torch==/g" requirements_min.txt
$SED -i -e "s/torchvision==/# torchvision==/g" requirements.txt
$SED -i -e "s/torchvision==/# torchvision==/g" requirements_min.txt
$SED -i -e "s/transformers==/# transformers==/g" requirements.txt
$SED -i -e "s/transformers==/# transformers==/g" requirements_min.txt
if python3 -c "import transformers" 2>/dev/null; then
    version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  transformers version: $version"
else
    pip3 install transformers==4.36.1
fi
$SED -i -e "s/xformers==/# xformers==/g" requirements.txt
$SED -i -e "s/xformers==/# xformers==/g" requirements_min.txt
if python3 -c "import xformers" 2>/dev/null; then
    version=$(python3 -c "import xformers; print(xformers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  xformers version: $version"
else
    pip3 install xformers==0.0.21
fi
pip3 install -r requirements_min.txt
pip3 install peft==0.10.0

huggingface-cli download Stable-X/yoso-normal-v1-5

python app.py
# otn-cli --node stable_normal --unittest
