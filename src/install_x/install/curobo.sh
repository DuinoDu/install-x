#!/usr/bin/env bash

_curfile=$(realpath $0)
cur=$(dirname $_curfile)
source $cur/base.sh

url=https://github.com/NVlabs/curobo.git
name=$(basename $url)
name=${name%.git}

prepare_github $url
cd $GITHUB/$name

python3 -c "import ${name}" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "${name} is already installed, skip"
    exit
fi

pip install -e . --no-build-isolation
