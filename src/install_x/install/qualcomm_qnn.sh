#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

function download_qnn() {
    # https://softwarecenter.qualcomm.com/api/download/software/qualcomm_neural_processing_sdk/v2.29.0.241129.zip
    qnn_version=2.29.0.241129
    export QNN_SDK_ROOT=$HOME/opt/qairt/$qnn_version
    if [ -d $QNN_SDK_ROOT ];then
        return
    fi
    opt=$HOME/opt
    mkdir -p $opt
    pushd $opt
    wget https://softwarecenter.qualcomm.com/api/download/software/qualcomm_neural_processing_sdk/v${qnn_version}.zip
    unzip v${qnn_version}.zip
    rm v${qnn_version}.zip
    popd
}

function setup_qnn() {
    if [[ -z "VIRTUAL_ENV" ]];then
        echo "Please run in python venv."
        exit
    fi

    if [[ -z "SCRIPTS" ]];then
        echo "SCRIPTS not defined"
        return
    fi
    if [[ -z "QNN_SDK_ROOT" ]];then
        echo "QNN_SDK_ROOT not defined"
        return
    else
        echo "QNN_SDK_ROOT: ${QNN_SDK_ROOT}"
    fi

    sudo ${QNN_SDK_ROOT}/bin/check-linux-dependency.sh
    # export CC=gcc CXX=g++
    sudo apt-get update && sudo apt-get install python3.10 python3-distutils libpython3.10
    cd ${QNN_SDK_ROOT}/bin; source ./envsetup.sh; cd - 
    python3 "${QNN_SDK_ROOT}/bin/check-python-dependency"
    
    # # install clang-14
    # source $SCRIPTS/install/install_clang.sh
    # install_type3 14
    # ${QNN_SDK_ROOT}/bin/envcheck -c

    # install ndk 
    bash $SCRIPTS/install/install_ndk.sh
}

download_qnn
setup_qnn
