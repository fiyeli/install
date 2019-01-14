#!/usr/bin/env bash
# Create main folder
echo "#### Creating main folder ####"
mkdir ~/FiyeliTest
cd ~/FiyeliTest

# Clone repos
echo "##### Cloning repos #####"
git clone https://github.com/pilbi/camera.git
git clone https://github.com/pilbi/core.git
git clone https://github.com/pilbi/api.git
git clone https://github.com/pilbi/Fiyeli-Darknet-NNPACK.git

# Adding env var
echo "#### Adding environment variables #####"
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

# Camera module
export FIYELI_CAMERA_SHOT="$FIYELI_CAMERA_DIR/camera.py"
echo "export FIYELI_CAMERA_SHOT=\"$FIYELI_CAMERA_DIR/camera.py\"" >> ~/.bashrc

# AI module
export FIYELI_AI_RUN="$FIYELI_AI_DIR/darknet detector person cfg/coco.data cfg/yolov3.cfg yolov3.weights "
echo "export FIYELI_AI_RUN=\"$FIYELI_AI_DIR/darknet detector person cfg/coco.data cfg/yolov3.cfg yolov3.weights \"" >> ~/.bashrc


echo "You still have to install the AI module (Fiyeli-Darknet-NNPACK), in order to do this you can check the Fiyeli-Darknet-NNPACK folder readme"