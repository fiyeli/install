# Install PeachPy
sudo pip install --upgrade git+https://github.com/Maratyszcza/PeachPy
# Install confu
sudo pip install --upgrade git+https://github.com/Maratyszcza/confu
# Install clang
sudo apt-get install clang
# Install Ninja
git clone https://github.com/ninja-build/ninja.git
cd ninja
git checkout release
./configure.py --bootstrap
export NINJA_PATH=$PWD

# Build NNPACK
cd
git clone https://github.com/digitalbrain79/NNPACK-darknet.git
cd NNPACK-darknet
confu setup
python ./configure.py --backend auto
$NINJA_PATH/ninja
sudo cp -a lib/* /usr/lib/
sudo cp include/nnpack.h /usr/include/
sudo cp deps/pthreadpool/include/pthreadpool.h /usr/include/

# Build darknet (with NNpack by default)
cd $FIYELI_AI_DIR
make
