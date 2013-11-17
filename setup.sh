#! /bin/bash
# Configure sources
# export DEBIAN_FRONTEND=noninteractive
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo bash -c "cat /etc/apt/sources.list | sed 's/wheezy /unstable /g' | sed 's/main/main contrib non-free/' | tee /etc/apt/sources.list"
sudo apt-get update

# Configure development environment
sudo apt-get install -y -q vim zsh git wget dos2unix
# shell environment...
wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
pushd ~
git clone https://github.com/rupa/z
popd
# .zshrc
cat << EOF >> ~/.zshrc
alias ls='ls --color=auto -h'
alias ll='ls -l'
alias gs='git status'
alias gm='git commit -m'
alias gma='git commit -a -m'
source ~/z/z.sh 
EOF
# vim configuration
git clone https://gist.github.com/4576917.git
cat 4576917/vimrc | sed 's/consolas:h16/Inconsolata\\ 14/' > ~/.vimrc
rm -rf 4576917
mkdir ~/.vim
pushd ~/.vim
mkdir colors
pushd colors
wget http://files.werx.dk/wombat.vim
dos2unix wombat.vim
popd
wget "http://www.vim.org/scripts/download_script.php\?src_id\=17123" -O nerdtree.zip
unzip nerdtree.zip
rm nerdtree.zip
wget "http://downloads.sourceforge.net/project/vim-latex/snapshots/vim-latex-1.8.23-20130116.788-git2ef9956.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fvim-latex%2Ffiles%2Fsnapshots%2F&ts=1384542687&use_mirror=softlayer-dal" -O latex.tar.gz
tar -xzvf latex.tar.gz
mv vim-latex*/* .
rm -r vim-latex*
rm latex.tar.gz
popd
# git configuration
git config --global user.name "Yan Wang"
git config --global user.email grapeot@gmail.com
git config --global push.default simple # eliminate the warning message of the new version git
# ssh configuration (won't take effect until restart)
sudo bash -c "cat /etc/ssh/sshd_config | sed 's/Port 22/Port 30/' | tee /etc/ssh/sshd_config"

# Installing desktop environment 
sudo apt-get install -y -q tig build-essential curl rsync tmux python rsync zip unzip unrar python-gtk2 python-wnck python-xlib xfce4 xfce4-power-manager xfce4-screenshooter xfce4-terminal xfce4-systemload-plugin vim-gtk evince pulseaudio cups cups-client ristretto wicd scim scim-pinyin ttf-wqy-microhei ttf-wqy-zenhei fonts-inconsolata gnome-screensaver 
sudo apt-get remove -y xscreensaver
wget http://font.ubuntu.com/download/ubuntu-font-family-0.80.zip
unzip ubuntu-font-family-0.80.zip
mkdir ~/.fonts
mv ubuntu-font-family-0.80/*.ttf ~/.fonts
rm -rf ubuntu-font-family-0.80
rm ubuntu-font-family-0.80.zip
fc-cache -fv
cp .tmux.conf ~
mkdir ~/.themes
pushd ~/.themes
wget http://gnome-look.org/CONTENT/content-files/150905-adwaita-x-dark-light-1.3.zip -O Adwaita.zip 
unzip Adwaita.zip
rm Adwaita.zip
ln -s /usr/share/themes/Adwaita/gtk-3.0 ~/.themes/Adwaita-X-dark/gtk-3.0
popd

# Optional software, uncomment to install
# map caps to control
sudo bash -c "cat /etc/default/keyboard | sed 's/XKBOPTIONS=\"\"/XKBOPTIONS=\"ctrl:nocaps\"/' | tee /etc/default/keyboard"
# quicktile
wget http://github.com/ssokolow/quicktile/zipball/master -O quicktile.zip
unzip quicktile.zip
cd ssokolow-quicktile*
sudo ./setup.py install
cd ..
mkdir ~/.config
cp quicktile.cfg ~/.config
sudo rm -rf ssokolow-quicktile*
rm quicktile.zip
# Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
# Dropbox
wget https://www.dropbox.com/download?dl=packages/debian/dropbox_1.6.0_amd64.deb -O dropbox.deb
sudo dpkg -i dropbox.deb
sudo apt-get install -f -y
rm google-chrome-stable_current_amd64.deb dropbox.deb
# Change the default shell in the end because it requires user interactions
chsh -s $(which zsh)
# Latex
# apt-get install latexmk latex-beamer

startx
