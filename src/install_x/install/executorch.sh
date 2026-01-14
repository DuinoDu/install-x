#!/usr/bin/env bash
# 
# bash $INSTALL/executorch.sh       # install by pip
# bash $INSTALL/executorch.sh 1     # install by source

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

create_venv 3.10

if python3 -c "import torch" 2>/dev/null; then
    version=$(python3 -c "import torch; print(torch.__version__)" 2>/dev/null || echo "Unknown")
    echo "  torch version: $version"
else
    pip3 install torch torchvision torchaudio
fi

if python3 -c "import transformers" 2>/dev/null; then
    version=$(python3 -c "import transformers; print(transformers.__version__)" 2>/dev/null || echo "Unknown")
    echo "  transformers version: $version"
else
    pip3 install transformers
fi

install_from_source=0
if [ -n "$1" ];then
    install_from_source=1
fi

if [[ $install_from_source == "1" ]]; then
    pip3 uninstall executorch -y
    OLD_GITHUB=$GITHUB
    GITHUB="."
    prepare_github https://github.com/pytorch/executorch.git 3.10 v1.0.1
    GITHUB=$OLD_GITHUB
    
    # TODO: add more scripts
else
    if python3 -c "import executorch" 2>/dev/null; then
        version=$(python3 -c "from executorch import version; print(version.__version__)" 2>/dev/null || echo "Unknown")
        echo "  executorch version: $version"
    else
        pip3 install executorch==1.0.1
    fi
fi

if [ Darwin = 'Darwin' ]; then
    brew install flatbuffers
elif [[ "$(uname)" == "Linux" ]]; then
    sudo apt install flatbuffers -y # not tested
else
    echo "Not supported"
fi

which flatc 
