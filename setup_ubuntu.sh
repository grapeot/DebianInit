#! /bin/bash
# Configure sources
sudo apt-get update

# Configure development environment
sudo apt-get install -y -q vim zsh git wget dos2unix python python-setuptools parallel tig build-essential curl htop rsync tmux zip unzip pkg-config
# shell environment...
wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
pushd ~
git clone https://github.com/rupa/z
popd
# .dotfiles
pushd ~
git clone --recursive https://github.com/grapeot/.dotfiles
./.dotfiles/deploy_linux.sh
popd
# git configuration
git config --global user.name "Yan Wang"
git config --global user.email grapeot@outlook.com
git config --global push.default simple # eliminate the warning message of the new version git
git config --global color.ui auto
git config --global core.fileMode false
# ssh configuration (won't take effect until restart)
sudo bash -c "cat /etc/ssh/sshd_config | sed 's/Port 22/Port 30/' | tee /etc/ssh/sshd_config"
# get pip and install trash-cli
curl https://bootstrap.pypa.io/get-pip.py | sudo python
sudo pip install trash-cli

# # Installing desktop environment 
# sudo apt-get install -y -q python-gtk2 python-xlib xfce4 xfce4-power-manager xfce4-screenshooter xfce4-terminal xfce4-systemload-plugin vim-gtk evince ristretto ttf-wqy-microhei ttf-wqy-zenhei fonts-inconsolata gnome-screensaver xauth x11-apps tightvncserver
# # Make the X11 work properly
# cat /etc/X11/Xwrapper.config | sed 's/console/anybody/' | sudo cat >> /etc/X11/Xwrapper.config
# sudo chown ubuntu:ubuntu ~/.Xauthority
# # Configure the fonts and themes
# sudo apt-get remove -y xscreensaver
# wget http://font.ubuntu.com/download/ubuntu-font-family-0.80.zip
# unzip ubuntu-font-family-0.80.zip
# mkdir ~/.fonts
# mv ubuntu-font-family-0.80/*.ttf ~/.fonts
# rm -rf ubuntu-font-family-0.80
# rm ubuntu-font-family-0.80.zip
# fc-cache -fv
# mkdir ~/.themes
# pushd ~/.themes
# wget https://dl.opendesktop.org/api/files/download/id/1460761610/150905-adwaita-x-dark-light-1.3.zip -O Adwaita.zip 
# unzip Adwaita.zip
# rm Adwaita.zip
# ln -s /usr/share/themes/Adwaita/gtk-3.0 ~/.themes/Adwaita-X-dark/gtk-3.0
# popd

# # Optional software, uncomment to install
# # quicktile
# wget http://github.com/ssokolow/quicktile/zipball/master -O quicktile.zip
# unzip quicktile.zip
# cd ssokolow-quicktile*
# sudo ./setup.py install
# cd ..
# mkdir ~/.config
# cp quicktile.cfg ~/.config
# sudo rm -rf ssokolow-quicktile*
# rm quicktile.zip
# # Chrome
# wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
# sudo dpkg -i google-chrome-stable_current_amd64.deb
# # Dropbox
# wget https://www.dropbox.com/download?dl=packages/debian/dropbox_1.6.0_amd64.deb -O dropbox.deb
# sudo dpkg -i dropbox.deb
# sudo apt-get install -f -y
# rm google-chrome-stable_current_amd64.deb dropbox.deb

# Change the default shell in the end because it requires user interactions
chsh -s $(which zsh)

# Mount s3fs specially for spot requests, add your own credentials here
# ./install_fuse.sh
