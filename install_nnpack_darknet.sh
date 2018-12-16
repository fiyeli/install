# Install PeachPy
sudo pip install --upgrade git+https://github.com/Maratyszcza/PeachPy
# Install confu
sudo pip install --upgrade git+https://github.com/Maratyszcza/confu
# Install Ninja
git clone https://github.com/ninja-build/ninja.git
cd ninja
git checkout release
./configure.py --bootstrap
export NINJA_PATH=$PWD
# Install clang
sudo apt-get install clang
git clone https://github.com/digitalbrain79/NNPACK-darknet.git

# Build NNPACK
cd NNPACK-darknet
confu setup
python ./configure.py --backend auto
$NINJA_PATH/ninja
sudo cp -a lib/* /usr/lib/
sudo cp include/nnpack.h /usr/include/
sudo cp deps/pthreadpool/include/pthreadpool.h /usr/include/

# Build darknet (with NNpack by default)
git clone https://github.com/pilbi/darknet-nnpack.git
cd darknet-nnpack
make
