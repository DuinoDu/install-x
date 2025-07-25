#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/HorizonRobotics/robo_orchard_lab
name=$(basename $url)
name=${name%.git}

prepare_github $url
cd $GITHUB/$name

# pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu118
bash $cur/torch.sh
# pip3 install spconv-cu120==2.3.8
bash $cur/spconv.sh

make version
pip3 install -e ".[finegrasp]"

bash $cur/graspnetAPI.sh
bash $cur/MinkowskiEngine.sh
pip3 install transforms3d==0.4.2 numpy==1.26.4

prepare_github https://github.com/mahaoxiang822/Scale-Balanced-Grasp
cd $GITHUB
git reset --hard HEAD
git apply $cur/patch/${name}.patch

sitepackage=$(python3 -c "import site;  print(site.getsitepackages()[0])")
cd $GITHUB/Scale-Balanced-Grasp/pointnet2
python setup.py build_ext --inplace
cp -r pointnet2 $sitepackage

cd $GITHUB/Scale-Balanced-Grasp/knn
python setup.py build_ext --inplace
cp -r knn $sitepackage
