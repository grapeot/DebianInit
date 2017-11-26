wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1604_8.0.61-1_amd64.deb
sudo apt-get update
sudo apt-get install cuda-8-0
wget "https://www.dropbox.com/s/brc0h339ineam7n/libcudnn6_6.0.21-1%2Bcuda8.0_amd64.deb?dl=1" -O cudnn.deb
sudo dpkg -i cudnn.deb
wget http://us.download.nvidia.com/tesla/384.66/nvidia-diag-driver-local-repo-ubuntu1604-384.66_1.0-1_amd64.deb
sudo dpkg -i nvidia-diag-driver-local-repo-ubuntu1604-384.66_1.0-1_amd64.deb
sudo apt-get install libcupti-dev
pip3 install tensorflow-gpu jupyter
export CUDA_HOME='/usr/local/cuda-8.0'
export LD_LIBRARY_PATH="/usr/local/cuda-8.0/lib:$LD_LIBRARY_PATH"
export PATH="/usr/local/cuda-8.0/bin:$PATH"
echo "Don't forget to update the .zshrc."
