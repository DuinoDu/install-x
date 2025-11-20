#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/huggingface/lerobot
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

bash $cur/torch.sh 2.4.1

pip install -e ".[all]"

pip install "huggingface_hub<0.26.0"
pip install flash-attn --no-build-isolation --upgrade
pip install "numpy<2.0"

tee -a Makefile <<-'EOF'

dataset_repo=lerobot/svla_so101_pickplace

vis-dataset:
	echo "https://huggingface.co/spaces/lerobot/visualize_dataset?path=%2Flerobot%2Fsvla_so101_pickplace"

train:
	export TOKENIZERS_PARALLELISM=false; \
	lerobot-train \
		--policy.path=lerobot/smolvla_base \
		--dataset.repo_id=$(dataset_repo) \
		--batch_size=64 \
		--steps=20000 \
		--output_dir=outputs/train/my_smolvla \
		--job_name=my_smolvla_training \
		--policy.device=cuda \
		--policy.push_to_hub=false \
		--wandb.enable=false
EOF
    $SED -i 's/    /\t/g' Makefile

if [[ "$(uname)" == "Darwin"  ]];then
    brew install ffmpeg@7
    device="mps"
elif [[ "$(uname)" == "Linux" ]]; then
    sudo apt install ffmpeg
    sudo ldconfig
    device="cuda"
elif [[ "$(uname)" == *"_NT"* ]]; then
    device="cpu"
fi

make DEVICE=${device} test-act-ete-train
make DEVICE=${device} test-act-ete-eval
