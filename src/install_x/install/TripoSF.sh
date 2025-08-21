#!/usr/bin/env bash
# Created by AI

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/VAST-AI-Research/TripoSF.git
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

# Install PyTorch 2.4.1
bash $cur/torch.sh 2.4.1

# Install dependencies
# Install dependencies with compatible versions
pip3 install trimesh==4.5.3 torch-scatter==2.1.2 open3d==0.18.0 numpy==1.24.4 omegaconf==2.3.0 safetensors easydict jaxtyping spconv

# Create ckpts directory for model weights
mkdir -p ckpts

# Download model weights from Hugging Face
if [ ! -d "ckpts/TripoSF" ]; then
    echo "Downloading TripoSF model weights..."
    pip3 install huggingface_hub
    python3 -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='VAST-AI/TripoSF', local_dir='ckpts/TripoSF')"
    ln -s `pwd`/ckpts/TripoSF/vae/pretrained_TripoSFVAE_256i1024o.safetensors ckpts/
fi

# Verify installation by running a simple test
echo "Verifying installation..."
python3 -c "import torch; print('PyTorch version:', torch.__version__)"
python3 -c "import trimesh; print('trimesh installed successfully')"

function help() {
    echo ""
    echo "TripoSF installation complete!"
    echo ""
    echo "To run mesh reconstruction:"
    echo "  python inference.py --mesh-path assets/examples/jacket.obj --output-dir outputs/ --config configs/TripoSFVAE_1024.yaml"
    echo ""
    echo "To launch Gradio UI:"
    echo "  python app.py"
    echo ""
    echo "Model weights are located in: ckpts/TripoSF/"
    echo "Example meshes are in: assets/examples/"
}

if [ $? -eq 0 ]; then
    help
fi
