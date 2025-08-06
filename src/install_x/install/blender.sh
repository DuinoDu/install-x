#!/usr/bin/env bash

# echo "Download blender from https://www.blender.org/download/"

blender_version=4.1.1
if [ -n "$1" ];then
    blender_version=$1
fi
big_version="${version%.*}"

system=
case "$(uname -s)" in
    Linux) system="linux" ;;
    Darwin) system="macos" ;;
    *) echo "Unsupported system" ;;
esac
march=
case "$(uname -m)" in
    x86_64) march="x86" ;;
    arm64) system="arm64" ;;
    *) echo "Unsupported match" ;;
esac

BLENDER_URL="https://download.blender.org/release/Blender${big_version}/blender-${blender_version}-${system}-${march}.tar.xz"
INSTALL_DIR="$HOME/opt/blender" # Or /opt/blender, /usr/local/blender etc.
BIN_PATH="$HOME/.local/bin" # For creating a symbolic link

if [ -f $BIN_PATH/blender ];then
    echo "$BIN_PATH/blender exists, skip install blender." 
    exit
fi

echo "Downloading Blender from $BLENDER_URL..."
if [ ! -f /tmp/blender.tar.xz ];then
    wget -q --show-progress "$BLENDER_URL" -O /tmp/blender.tar.xz
fi

if [ $? -ne 0  ]; then
    echo "Error: Failed to download Blender."
    exit 1
fi

echo "Extracting Blender to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
tar -xf /tmp/blender.tar.xz -C "$INSTALL_DIR" --strip-components=1

if [ $? -ne 0  ]; then
    echo "Error: Failed to extract Blender."
    exit 1
fi

echo "Creating symbolic link in $BIN_PATH..."
sudo ln -sf "$INSTALL_DIR/blender" "$BIN_PATH/blender"

if [ $? -ne 0  ]; then
    echo "Error: Failed to create symbolic link. You may need to run this script with sudo."
    exit 1
fi

echo "Blender installation complete. You can now run 'blender' from your terminal."
rm /tmp/blender.tar.xz # Clean up the downloaded archive


function setup_blender() {
    if [ -z BL_HOME ]; then
        echo "Please install blender and setup $BL_HOME"
        return
    fi
    $BL_HOME/python/bin/python3.11 -m ensurepip
}
setup_blender
