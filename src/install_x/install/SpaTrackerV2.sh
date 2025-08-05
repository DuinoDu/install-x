#!/usr/bin/env bash
# Created by AI

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/henry123-boy/SpaTrackerV2.git
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

python3 -c "import ${name}" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "${name} is already installed, skip"
    exit
fi

# Use python3.10 specifically
python3.10 -m pip install --upgrade pip

# Install PyTorch 2.4.1 with CUDA support
bash $cur/torch.sh

# Install required packages
pip3 install -r requirements.txt

# Download model parameters
if [ -f "scripts/download.sh" ]; then
    bash scripts/download.sh
else
    echo "Warning: download script not found, skipping model download"
fi

# Verify installation
python3 -c "import torch; print(f'PyTorch version: {torch.__version__}')"
python3 -c "import gradio; print(f'Gradio version: {gradio.__version__}')"

# Run demo to verify setup
echo "Running demo to verify installation..."
if [ -f "app.py" ]; then
    echo "Starting Gradio demo..."
    timeout 30 python3.10 app.py &
    DEMO_PID=$!
    sleep 10
    kill $DEMO_PID 2>/dev/null || true
    echo "Demo started successfully"
else
    echo "Running inference example..."
    if [ -d "examples" ]; then
        python3.10 inference.py --data_type="RGB" --data_dir="examples" --video_name="protein" --fps=3
    else
        echo "No examples directory found, skipping inference test"
    fi
fi

echo "SpaTrackerV2 installation completed successfully!"

function help() {
    echo "SpaTrackerV2 Installation Complete"
    echo "Usage:"
    echo "  - Run Gradio demo: python3.10 app.py"
    echo "  - Run monocular inference: python3.10 inference.py --data_type='RGB' --data_dir='examples' --video_name='protein' --fps=3"
    echo "  - Run RGBD inference: python3.10 inference.py --data_type='RGBD' --data_dir='assets/example1' --video_name='snowboard' --fps=1"
}

if [ $? -eq 0 ]; then
    help
fi
