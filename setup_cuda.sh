# This is a script configuring deep learning environment on Ubuntu 14.04 LTS.

wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_6.5-14_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1404_6.5-14_amd64.deb
sudo apt-get update
sudo apt-get -q -y install python-numpy python-scipy python-nose libopenblas-dev linux-image-generic
sudo apt-get -q -y dist-upgrade
sudo apt-get -q -y install cuda
sudo pip install theano
echo 'export CUDA_ROOT=/usr/local/cuda/bin' >> ~/.zshrc
echo 'export PATH=$PATH:$CUDA_ROOT' >> ~/.zshrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.zshrc

echo "Need to reboot for the driver to take effect."
