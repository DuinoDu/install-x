if [[ -z "$INSTALL_X_CACHE" ]];then
    INSTALL_X_CACHE=$HOME/.cache/install-x
fi
if [ ! -d $INSTALL_X_CACHE ];then
    mkdir -p $INSTALL_X_CACHE
fi

export CC=gcc CXX=g++
SED=sed
if [ -f /opt/homebrew/bin/gsed ];then
    SED=/opt/homebrew/bin/gsed
fi

GITHUB=$INSTALL_X_CACHE
CACHE_DIR=$INSTALL_X_CACHE

function prepare_github() {
    pushd $INSTALL_X_CACHE
    
    url=$1
    name=$(basename $url)
    name=${name%.git}
    if [ ! -d $name ];then
        if [ -n "$2" ];then
            git clone $url --recursive --branch $2
        else
            git clone $url --recursive 
        fi
    fi
    popd
}

function get_cuda_version() {
    if ! hash nvcc 2>/dev/null;then
        echo 'nvcc not found, please install CUDA first.'
        exit
    fi
    version=`nvcc --version | grep -e "cuda_" | cut -d "/" -f 1 | cut -d " " -f 2`
    echo $version
}
