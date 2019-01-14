#!/usr/bin/env bash
# Create main folder
echo "Creating Fiyeli folder..."
mkdir ~/Fiyeli
cd ~/Fiyeli

# Clone repos
echo "Cloning Fiyeli base repos..."
git clone https://github.com/pilbi/camera.git
git clone https://github.com/pilbi/core.git
git clone https://github.com/pilbi/api.git
git clone https://github.com/pilbi/Fiyeli-Darknet-NNPACK.git

# Adding env var
echo "Adding Fiyeli environment variables..."
echo "# Fiyeli Env Var" >> ~/.bashrc

# Fiyeli directories
export FIYELI_DIR=`pwd`
echo "export FIYELI_DIR=`pwd`" >> ~/.bashrc

export FIYELI_CORE_DIR="$FIYELI_DIR/core"
echo "export FIYELI_CORE_DIR=\"$FIYELI_DIR/core\"" >> ~/.bashrc

export FIYELI_CAMERA_DIR="$FIYELI_DIR/camera"
echo "export FIYELI_CAMERA_DIR=\"$FIYELI_DIR/camera\"" >> ~/.bashrc

export FIYELI_AI_DIR="$FIYELI_DIR/Fiyeli-Darknet-NNPACK"
echo "export FIYELI_AI_DIR=\"$FIYELI_DIR/Fiyeli-Darknet-NNPACK\"" >> ~/.bashrc

export FIYELI_API_DIR="$FIYELI_DIR/api"
echo "export FIYELI_AI_DIR=\"$FIYELI_DIR/api\"" >> ~/.bashrc

export FIYELI_IMAGES="$FIYELI_CORE_DIR/img"
echo "export FIYELI_IMAGES=\"$FIYELI_CORE_DIR/img\""

export FIYELI_DATA="$FIYELI_CORE_DIR/data"
echo "export FIYELI_DATA=\"$FIYELI_CORE_DIR/data\""

# Camera module
export FIYELI_CAMERA_SHOT="$FIYELI_CAMERA_DIR/camera.py"
echo "export FIYELI_CAMERA_SHOT=\"$FIYELI_CAMERA_DIR/camera.py\"" >> ~/.bashrc

# AI module
export FIYELI_AI_RUN="$FIYELI_AI_DIR/darknet detector person cfg/coco.data cfg/yolov3.cfg yolov3.weights "
echo "export FIYELI_AI_RUN=\"$FIYELI_AI_DIR/darknet detector person cfg/coco.data cfg/yolov3.cfg yolov3.weights \"" >> ~/.bashrc
