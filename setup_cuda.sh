# This is a script configuring deep learning environment on Ubuntu 14.04 LTS.

wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_6.5-14_amd64.deb
sudo dpkg -i cuda-repo-ubuntu1404_6.5-14_amd64.deb
sudo apt-get update
sudo apt-get -q -y install cuda

echo "Need to reboot for the driver to take effect."
