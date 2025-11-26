#!/usr/bin/env bash

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

if python3 -c "import executorch" 2>/dev/null; then
    version=$(python3 -c "from executorch import version; print(version.__version__)" 2>/dev/null || echo "Unknown")
    echo "  executorch version: $version"
else
    pip3 install executorch
fi

if [ Darwin = 'Darwin' ]; then
    brew install flatbuffers
elif [[ "$(uname)" == "Linux" ]]; then
    sudo apt install flatbuffers -y # not tested
else
    echo "Not supported"
fi

which flatc 
