#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

#   torch   torchvision
#   1.11.0  0.12.0
#   1.13.1  0.14.1
#   2.0.x   0.15.x
#   2.1.x   0.16.x
#   2.2.x   0.17.x
#   2.3.x   0.18.x
#   2.4.x   0.19.x
#   2.5.x   0.20.x
function find_torchvision_version() {
    if [ ! -n "$1" ];then
        echo "find_torchvision_version [torch version]"
        exit 1
    fi
    major=`echo $1 | cut -d"." -f1` 
    minor=`echo $1 | cut -d"." -f2` 
    reverse=`echo $1 | cut -d"." -f3` 

    if [[ "$major" == *"1"* ]]; then
        tv_minor=$(( $minor + 1 ))
    elif  [[ "$major" == *"2"*  ]]; then
        tv_minor=$(( $minor + 15 ))
    fi
    tv_version="0.${tv_minor}.${reverse}"
    
    # patch
    if [[ "$1" == "2.0.1" ]]; then
        tv_version="0.15.2"
    fi
    echo ${tv_version}
}

# Usage:
#   bash torch.sh [version, 1.13 or 2.x, default is 2.4.1]
#
#   cu121: torch==2.1.x, 2.2.x, 2.3.x, 2.4.x 2.5.x
#   cu124: torch==2.4.x 2.5.x
#   cu126: torch==2.6.0
#   cu128: torch==2.7.0
#
#   torch>=2.5 DON'T support py38
#
#   DEFAULT: py3.10 - cuda124 - torch 2.4.1 torchvision 0.19.1
python3 -c "import torch" 2>/dev/null
if [ $? -eq 0 ]; then
    if [ "${FORCE_INSTALL_TORCH}"x = "1"x ]; then
        echo "override, install torch ..."
    else
        echo "torch is already installed, skip"
        return
    fi
fi

torch_version=2.4.1
if [ -n "$1" ];then
    torch_version=$1
fi
tv_version=$(find_torchvision_version $torch_version)

if [ -z "$FORCE_CUDA_VERSION" ];then
    version=$(get_cuda_version)
    cu_version=
    if [ -n "$2" ];then
        cu_version="$2"
    elif [[ "$version" == *"11.6"*  ]]; then
        cu_version="cu116"
    elif [[ "$version" == *"11.7"*  ]]; then
        cu_version="cu117"
    elif [[ "$version" == *"12.1"* ]]; then
        cu_version="cu121"
    elif [[ "$version" == *"12.2"* ]]; then
        cu_version="cu121"
    elif [[ "$version" == *"12.3"* ]]; then
        cu_version="cu121"
    elif [[ "$version" == *"12.4"* ]]; then
        cu_version="cu124"
    elif [[ "$version" == *"12.5"* ]]; then
        cu_version="cu124"
    elif [[ "$version" == *"12.6"* ]]; then
        # cu_version="cu126"
        cu_version="cu124"
    elif [[ "$version" == *"12.9"* ]]; then
        cu_version="cu128"
    else
        echo "[ERROR] Unknown cuda version: ${version}"
        exit
    fi
else
    cu_version=$FORCE_CUDA_VERSION
fi

python_version=3.10 
pytorch_cache=python_${python_version}_torch_${torch_version}_torchvision_${tv_version}
if [ -d ${CACHE_DIR}/${pytorch_cache} ];then
    echo "Install pytorch by link to ${CACHE_DIR}/${pytorch_cache}"
    src_site_package=${CACHE_DIR}/${pytorch_cache}/env/.venv/lib/python3.10/site-packages
    dst_site_package=$(python3 -c "import site; print(site.getsitepackages()[0])")

    if [ ! -d ${src_site_package} ]; then
        echo "${src_site_package} not found"
        return
    fi
    if [ ! -d ${dst_site_package} ]; then
        echo "${dst_site_package} not found"
        return
    fi

    for f in `ls ${src_site_package}`; do
        src=${src_site_package}/$f
        dst=${dst_site_package}/$f
        if [[ -e $dst || -L $dst ]]; then
            rm -rf $dst
        fi
        # echo "ln -s $src $dst"
        ln -s $src $dst
    done

else
    pip3 install torch==${torch_version} torchvision==${tv_version} --index-url https://download.pytorch.org/whl/${cu_version}
fi
