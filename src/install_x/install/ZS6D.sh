#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/PhilippAuss/ZS6D
name=$(basename $url)
name=${name%.git}

prepare_github $url 3.10
cd $GITHUB/$name

# If have patch, uncomment below.
# git reset --hard HEAD
# git apply $cur/patch/${name}.patch

# python3 -c "import ${name}" 2>/dev/null
# if [ $? -eq 0 ]; then
#     echo "${name} is already installed, skip"
#     exit
# fi

bash $cur/torch.sh
pip3 install tqdm
pip3 install timm
pip3 install matplotlib
pip3 install scikit-learn
pip3 install opencv-python
pip3 install git+https://github.com/lucasb-eyer/pydensecrf.git@dd070546eda51e21ab772ee6f14807c7f5b1548b
pip3 install transforms3d
pip3 install pillow
pip3 install plyfile
pip3 install trimesh
pip3 install imageio
pip3 install pypng
pip3 install vispy
pip3 install pyopengl
pip3 install pyglet
pip3 install numba
pip3 install jupyter

git clone https://github.com/haberger/ZS6D_template_rendering
pip3 install blenderproc==2.6.2
pip3 install open3d
pip3 install pyrender
pip3 install opencv-python
pip3 install trimesh

pip3 install jupytext
jupytext --to py test_zs6d.ipynb

if [ ! -f Makefile ];then
    tee -a Makefile <<-'EOF'

render_template:
    echo "update bop_templates_cfg.yaml"
    cd ZS6D_template_rendering && \
    blenderproc run render_bop_templates.py bop_templates_cfg.yaml

prepare:
    python prepare_templates_and_gt.py

infer:
    python test_zs6d.py 
EOF
    $SED -i 's/    /\t/g' Makefile
fi
make infer 
