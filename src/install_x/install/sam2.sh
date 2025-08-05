#!/bin/bash

# SAM2 Installation Script
# Based on SAM-6D.sh and base.sh patterns

set -e

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

# Configuration
REPO_URL="https://github.com/facebookresearch/sam2.git"
PYTHON_VERSION="3.10"
PROJECT_NAME="sam2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
END_COLOR='\033[0m'

echo -e "${GREEN}Starting SAM2 installation...${END_COLOR}"

# Step 1: Clone repository and create virtual environment
echo -e "${ORANGE}Step 1: Cloning SAM2 repository...${END_COLOR}"
prepare_github $REPO_URL $PYTHON_VERSION

# Change to project directory
cd $GITHUB/$PROJECT_NAME

# Step 2: Install SAM2 package
echo -e "${ORANGE}Step 2: Installing SAM2 package...${END_COLOR}"
# Install SAM2 dependencies manually since pyproject.toml is incomplete
bash $cur/torch.sh 2.5.1
pip install opencv-python pillow matplotlib
pip install jupyter ipywidgets
pip install -e .

# Step 3: Install additional dependencies for notebooks if needed
echo -e "${ORANGE}Step 3: Installing notebook dependencies...${END_COLOR}"
pip install -e ".[notebooks]"

# Step 5: Download model checkpoints
echo -e "${ORANGE}Step 5: Downloading model checkpoints...${END_COLOR}"
if [ -d "checkpoints" ]; then
    cd checkpoints
    if [ -f "download_ckpts.sh" ]; then
        chmod +x download_ckpts.sh
        ./download_ckpts.sh
    else
        echo -e "${RED}Warning: download_ckpts.sh not found in checkpoints directory${END_COLOR}"
    fi
    cd ..
else
    echo -e "${RED}Warning: checkpoints directory not found${END_COLOR}"
fi

# Step 6: Verify installation
echo -e "${ORANGE}Step 6: Verifying installation...${END_COLOR}"
python -c "import torch; print('PyTorch version:', torch.__version__)"
python -c "import sam2; print('SAM2 imported successfully')"

# Step 7: Run demo if available
echo -e "${ORANGE}Step 7: Running demo...${END_COLOR}"
if [ -f "demo.py" ]; then
    echo -e "${GREEN}Running demo.py...${END_COLOR}"
    python demo.py
elif [ -d "notebooks" ]; then
    echo -e "${GREEN}Demo notebooks available in notebooks/ directory${END_COLOR}"
    ls notebooks/
else
    echo -e "${ORANGE}No demo found, but installation completed successfully${END_COLOR}"
fi

echo -e "${GREEN}SAM2 installation completed successfully!${END_COLOR}"
echo -e "${GREEN}Project location: $GITHUB/$PROJECT_NAME${END_COLOR}"
echo -e "${GREEN}Virtual environment: $GITHUB/$PROJECT_NAME/.venv${END_COLOR}"
