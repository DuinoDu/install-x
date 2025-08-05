
###################### ENVS ######################

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

# better for echo log
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
END_COLOR='\033[0m' # No Color


###################### FUNCTIONS ######################
# __all__ =  [
#       "get_cuda_version",
#       "create_venv",
#       "is_venv_python",
#       "conda_to_pip",
#       "prepare_github",
# ]

function get_cuda_version() {
    if ! hash nvcc 2>/dev/null;then
        echo 'nvcc not found, please install CUDA first.'
        exit
    fi
    version=`nvcc --version | grep -e "cuda_" | cut -d "/" -f 1 | cut -d " " -f 2`
    echo $version
}


# Desc: Create python venv using rye.
# Usage: 
#   create_venv 3.10
function create_venv() {
    if [ -n "$1" ];then
        res=$(is_venv_python | tail -n 1)
        if [ $res -eq 0 ] && [ ! -d .venv ]; then
            ln -s $VIRTUAL_ENV .venv
        fi  

        if [ ! -d .venv ];then
            echo "Install python venv $1"
            rye=$HOME/.rye/shims/rye
            if [ -f setup.py ];then
                mv setup.py setup.py.bakup
            fi

            if [ ! -f pyproject.toml ];then
                $rye init
            fi
            $rye pin $1
            $rye sync

            if [ -f setup.py.bakup ];then
                mv setup.py.bakup setup.py 
            fi

            get_pip_cache=$HOME/.cache/get-pip.py
            if [ ! -f $get_pip_cache ];then
                curl https://bootstrap.pypa.io/get-pip.py -o $get_pip_cache
            fi
            .venv/bin/python3 $get_pip_cache
            mv .venv /tmp/${name}_venv
            git clean -f -d
            mv /tmp/${name}_venv .venv
        fi
        source .venv/bin/activate
    else
        if [ -d .venv ];then
            source .venv/bin/activate
        else
            res=$(is_venv_python | tail -n 1)
            if [ $res -eq 0 ]; then
                ln -s $VIRTUAL_ENV .venv
                source .venv/bin/activate
            else
                echo "No venv found, nor python_version select, exit"
            fi  
        fi
    fi
    
    if [[ -v "$VIRTUAL_ENV" ]];then
        pip3_bin=$VIRTUAL_ENV/bin/pip3
        if [ ! -f $pip3_bin ];then
            wget -O- https://bootstrap.pypa.io/get-pip.py | python3
            which pip3
        fi
    fi
}



# Usage:
#   res=$(is_venv_python | tail -n 1)
#   if [ $res -eq 0 ]; then
#       Now it is in python venv, do something, 
#   fi  
function is_venv_python() {
    python_path=$(which python 2>/dev/null || which python3 2>/dev/null)

    if [ -z "$python_path" ]; then
        echo "python/python3 not found"
        echo "2"
    fi

    if echo "$python_path" | grep -q -E '/(venv|virtualenv|env|\.env|\.venv|ENV|\.tox)/bin/python'; then
        echo "current python: $(dirname $(dirname $python_path))"
        echo "0"
    else
        echo "find python, but not in venv"
        echo "1"
    fi
}


function conda_to_pip() {
    if python -c "import yaml" &> /dev/null; then
        echo ""
    else
       pip3 install pyyaml 
    fi

    python -c "
import yaml
out = open('$2', 'a')
with open('$1', 'r') as f:
    data = yaml.safe_load(f)
for key, value in data.items():
    if key == 'dependencies':
        for dep in value:
            if isinstance(dep, dict) and 'pip' in dep:
                for item in dep['pip']:
                    out.write(item + '\n')
out.close()
"
}


# Desc: Create project from github and create venv if required. 
# Usage: 
#   Without venv
#   >> prepare_github https://github.com/.../...
#   With venv
#   >> prepare_github https://github.com/.../... 3.10
#   With venv, branch_name
#   >> prepare_github https://github.com/.../... 3.10 branch_name
function prepare_github() {
    if [ ! -d $GITHUB ];then
        mkdir -p $GITHUB
    fi
    pushd $GITHUB
    
    url=$1
    name=$(basename $url)
    name=${name%.git}
    if [ ! -d $name ];then
        if [ -n "$3" ];then
            git_args="--branch $3 --recursive"
        else
            git_args="--recursive"
        fi
        git clone $url ${git_args} 
    fi
    cd $name 

    if [ -n "$2" ];then
        create_venv $2
    fi
    popd
}
