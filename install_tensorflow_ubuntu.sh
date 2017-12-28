wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo apt-get update
sudo apt-get install -y cuda-8-0
wget "https://www.dropbox.com/s/op9hg576l36li8u/cudnn_ubuntu_8.0.deb?dl=1"
mv "cudnn_ubuntu_8.0.deb?dl=1" cudnn.deb
sudo dpkg -i cudnn.deb
wget http://us.download.nvidia.com/tesla/384.66/nvidia-diag-driver-local-repo-ubuntu1604-384.66_1.0-1_amd64.deb
sudo dpkg -i nvidia-diag-driver-local-repo-ubuntu1604-384.66_1.0-1_amd64.deb
sudo apt-get install -y libcupti-dev python3-dev python3-pip
pip3 install tensorflow-gpu jupyter
echo export CUDA_HOME='/usr/local/cuda-8.0' >> ~/.zshrc
echo export LD_LIBRARY_PATH='/usr/local/cuda-8.0/lib:$LD_LIBRARY_PATH' >> ~/.zshrc
echo export PATH='/usr/local/cuda-8.0/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
