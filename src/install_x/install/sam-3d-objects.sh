#!/usr/bin/env bash
# Created by AI

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

set -eo pipefail

url=https://github.com/facebookresearch/sam-3d-objects.git
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10

repo_dir=$GITHUB/$name
cd $repo_dir

$SED -i -e "s/^bpy==/# bpy==/g" requirements.txt
$SED -i -e "s/^torchaudio==/# torchaudio==/g" requirements.txt

export PIP_DEFAULT_TIMEOUT=600

if [ -z "${CONDA_PREFIX:-}" ]; then
    if [ -n "${VIRTUAL_ENV:-}" ]; then
        export CONDA_PREFIX=$VIRTUAL_ENV
    elif [ -d .venv ]; then
        export CONDA_PREFIX=$(realpath .venv)
    fi
fi

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

# python3 -c "import ${name}" 2>/dev/null
# if [ $? -eq 0 ]; then
#     echo "${name} is already installed, skip"
#     exit
# fi

bash $cur/torch.sh 2.4.1
# python3 -m pip install torchaudio==2.5.1+cu121 --index-url https://download.pytorch.org/whl/cu121
# export PIP_EXTRA_INDEX_URL="https://pypi.ngc.nvidia.com https://download.pytorch.org/whl/cu121"

python3 -m pip install -e '.[dev]'
python3 -m pip install -e '.[p3d]'

# export PIP_FIND_LINKS="https://nvidia-kaolin.s3.us-east-2.amazonaws.com/torch-2.5.1_cu121.html"
python3 -m pip install -e '.[inference]'

python3 -m pip install "huggingface-hub[cli]<1.0"
if ! command -v hf >/dev/null 2>&1; then
    echo "hf CLI not found even after installation"
    exit 1
fi

if [ -f patching/hydra ]; then
    pushd patching >/dev/null
    chmod +x hydra
    ./hydra
    popd >/dev/null
fi

tag=hf
ckpt_dir=checkpoints/${tag}
if [ ! -f ${ckpt_dir}/pipeline.yaml ]; then
    mkdir -p checkpoints
    tmp_dir=checkpoints/${tag}-download
    rm -rf ${tmp_dir}
    mkdir -p ${tmp_dir}
    hf_token_args=()
    if [ -n "${HF_TOKEN:-}" ]; then
        hf_token_args+=(--token "$HF_TOKEN")
    fi
    hf download \
        --repo-type model \
        --local-dir ${tmp_dir} \
        --max-workers 1 \
        "${hf_token_args[@]}" \
        facebook/sam-3d-objects
    if [ -d ${tmp_dir}/checkpoints ]; then
        rm -rf ${ckpt_dir}
        mv ${tmp_dir}/checkpoints ${ckpt_dir}
    fi
    rm -rf ${tmp_dir}
fi
if [ ! -f ${ckpt_dir}/pipeline.yaml ]; then
    echo "Checkpoint download failed. Please ensure Hugging Face access token is available."
    exit 1
fi

tee -a Makefile <<-'EOF'

infer:
    python demo.py
EOF
$SED -i 's/    /\t/g' Makefile
