#!/usr/bin/env bash

# Created by AI
_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/microsoft/VibeVoice.git
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

# Install PyTorch with torch.sh
bash $cur/torch.sh 2.4.1

# Install dependencies from pyproject.toml
pip3 install accelerate==1.6.0
pip3 install transformers==4.51.3
pip3 install "llvmlite>=0.40.0"
pip3 install "numba>=0.57.0"
pip3 install diffusers
pip3 install tqdm
pip3 install numpy
pip3 install scipy
pip3 install librosa
pip3 install ml-collections
pip3 install absl-py
pip3 install gradio
pip3 install av
pip3 install aiortc

# Install in development mode
pip3 install -e .

# Install huggingface_hub for model downloads
pip3 install huggingface_hub

# Install FFmpeg for audio processing
if ! command -v ffmpeg &> /dev/null; then
    echo "Installing FFmpeg..."
    sudo apt update && sudo apt install ffmpeg -y
fi

# Optional: Install flash attention
bash $cur/flash_attn.sh

# Download model files (VibeVoice-1.5B variant)
echo "Downloading VibeVoice-1.5B model..."
if python3 -c "import huggingface_hub" 2>/dev/null; then
    python3 -c "
from huggingface_hub import snapshot_download
snapshot_download(repo_id='microsoft/VibeVoice-1.5B', local_dir='./models/VibeVoice-1.5B')
"
else
    echo "huggingface_hub not available, skipping model download"
    echo "You can manually download models from: https://huggingface.co/microsoft/VibeVoice-1.5B"
fi

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'
demo:
    python demo/gradio_demo.py --model_path microsoft/VibeVoice-1.5B --share

infer:
    python demo/inference_from_file.py --model_path microsoft/VibeVoice-1.5B --txt_path demo/text_examples/1p_abs.txt --speaker_names Alice
EOF
    $SED -i 's/    /\t/g' Makefile
fi

# Test the installation
echo "Testing VibeVoice installation..."
python3 -c "import vibevoice; print('VibeVoice imported successfully')"

# Run a simple demo to verify installation
echo "Installation completed. You can run 'make demo' to start the Gradio web interface."
