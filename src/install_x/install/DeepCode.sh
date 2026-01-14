#!/usr/bin/env bash
# Created by AI

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/HKUDS/DeepCode.git
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10

cd $GITHUB/$name

# # Install PyTorch using the shared helper (defaults to 2.4.1)
# bash $cur/torch.sh

# Refresh pip tooling before installing project dependencies
pip3 install --upgrade pip setuptools wheel
pip3 install -r requirements.txt

echo "Please populate mcp_agent.secrets.yaml with your API keys before running DeepCode end-to-end."

# Quick sanity check from README: CLI interface help flag exits quickly and validates startup path
python cli/main_cli.py --help
