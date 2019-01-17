# Install PeachPy
sudo pip install --upgrade git+https://github.com/Maratyszcza/PeachPy
# Install confu
sudo pip install --upgrade git+https://github.com/Maratyszcza/confu
# Install clang
sudo apt-get install clang
# Install Ninja
sudo apt-get install ninja

# Build NNPACK
cd
git clone https://github.com/digitalbrain79/NNPACK-darknet.git
cd NNPACK-darknet
confu setup
python ./configure.py --backend auto
ninja -j 1 # You can remove -j 1 to enable multithreading but it's dangerous on Raspberry pi 3
sudo cp -a lib/* /usr/lib/
sudo cp include/nnpack.h /usr/include/
sudo cp deps/pthreadpool/include/pthreadpool.h /usr/include/

# Build darknet (with NNpack by default)
cd $FIYELI_AI_DIR
make
