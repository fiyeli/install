#! /bin/sh

### BEGIN INIT INFO
# Provides:		Fiyeli env var
# Short-Description:	Provides Fiyeli environment variables
### END INIT INFO

# Fiyeli directories
export FIYELI_DIR="$HOME/Fiyeli"

export FIYELI_CORE_DIR="$FIYELI_DIR/core"

export FIYELI_CAMERA_DIR="$FIYELI_DIR/camera"

export FIYELI_AI_DIR="$FIYELI_DIR/Fiyeli-Darknet-NNPACK"

export FIYELI_API_DIR="$FIYELI_DIR/api"

export FIYELI_IMAGES="$FIYELI_CORE_DIR/img"

export FIYELI_DATA="$FIYELI_CORE_DIR/data"

# Camera module
export FIYELI_CAMERA_SHOT="$FIYELI_CAMERA_DIR/camera.py"

# AI module
export FIYELI_AI_RUN="$FIYELI_AI_DIR/darknet detector person $FIYELI_AI_DIR/cfg/coco.data $FIYELI_AI_DIR/cfg/yolov2.cfg $FIYELI_AI_DIR/yolov2.weights"

# Main routine
export FIYELI_CORE_ROUTINE="$FIYELI_CORE_DIR/routine.py"

exit 0