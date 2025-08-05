#!/usr/bin/env bash
# Created by AI

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/DepthAnything/Depth-Anything-V2.git
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

# Install PyTorch using torch.sh
bash $cur/torch.sh 2.4.1

# Install requirements
echo "Installing requirements..."
pip install -r requirements.txt

# Create checkpoints directory and download model weights
echo "Creating checkpoints directory..."
mkdir -p checkpoints

# Download model checkpoints from Hugging Face
echo "Downloading model checkpoints..."
if [ ! -f checkpoints/depth_anything_v2_vits.pth ]; then
    echo "Downloading Small model..."
    wget -O checkpoints/depth_anything_v2_vits.pth "https://huggingface.co/depth-anything/Depth-Anything-V2-Small/resolve/main/depth_anything_v2_vits.pth"
fi

if [ ! -f checkpoints/depth_anything_v2_vitb.pth ]; then
    echo "Downloading Base model..."
    wget -O checkpoints/depth_anything_v2_vitb.pth "https://huggingface.co/depth-anything/Depth-Anything-V2-Base/resolve/main/depth_anything_v2_vitb.pth"
fi

if [ ! -f checkpoints/depth_anything_v2_vitl.pth ]; then
    echo "Downloading Large model..."
    wget -O checkpoints/depth_anything_v2_vitl.pth "https://huggingface.co/depth-anything/Depth-Anything-V2-Large/resolve/main/depth_anything_v2_vitl.pth"
fi

# Verify setup by running a quick test
echo "Verifying installation..."
python3 -c "import torch; import cv2; import matplotlib; import gradio; print('All dependencies installed successfully')"

# Run demo to verify everything works
echo "Running demo to verify setup..."
if [ -d "assets/examples" ]; then
    echo "Running image demo..."
    python3 run.py --encoder vitl --img-path assets/examples --outdir depth_vis
    echo "Demo completed successfully! Check depth_vis/ directory for output."
else
    echo "No example images found, skipping demo run."
fi

echo ""
echo "Setup completed successfully!"
echo "Available commands:"
echo "  python run.py --encoder vitl --img-path <your-images> --outdir <output-dir>"
echo "  python run_video.py --encoder vitl --video-path <your-videos> --outdir <output-dir>"
echo "  python app.py  # For Gradio web interface"

function help() {
    echo "Usage:"
    echo "  Image inference: python run.py --encoder vitl --img-path assets/examples --outdir depth_vis"
    echo "  Video inference: python run_video.py --encoder vitl --video-path assets/examples_video --outdir video_depth_vis"
    echo "  Gradio interface: python app.py"
    echo ""
    echo "Available models: vitl (Large), vitb (Base), vits (Small)"
    echo "Model checkpoints are in checkpoints/ directory"
}

if [ $? -eq 0 ]; then
    help
fi
