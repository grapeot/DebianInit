# echo Please install vim and configure sudo manually
# su 

# echo Configure sources
# sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
# sudo bash -c "cat /etc/apt/sources.list | sed 's/wheezy /unstable /g' | sed 's/main/main contrib non-free/' | tee /etc/apt/sources.list"
# sudo apt-get update

# echo Configure development environment
# sudo apt-get install zsh git tig build-essential wget curl rsync 

# echo shell environment...
# chsh -s $(which zsh)
# wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
# cd ~
# git clone https://github.com/rupa/z
# echo .zshrc...
# echo "alias ls='ls --color=auto -h'" >> ~/.zshrc
# echo "alias ll='ls -l'" >> ~/.zshrc
# echo "alias gs='git status'" >> ~/.zshrc
# echo "alias gm='git commit -m'" >> ~/.zshrc
# echo "alias gma='git commit -a -m'" >> ~/.zshrc
# echo source ~/z/z.sh >> ~/.zshrc
# 
# echo vim configuration...
# git clone https://gist.github.com/4576917.git
# cat 4576917/vimrc | sed 's/consolas:h16/Inconsolata\\ 14/' > ~/.vimrc
# rm -rf 4576917
# mkdir ~/.vim
# cd ~/.vim
# mkdir colors
# cd colors
# wget http://files.werx.dk/wombat.vim

# mv wombat.vim wombat2.vim
# cat wombat2.vim | dos2unix > wombat.vim
# rm wombat2.vim
# cd ..
# cd ~

# echo git configuration
# git config --global user.name "Yan Wang"
# git config --global user.email grapeot@gmail.com

# echo "ssh configuration (won't be effected until next restart)"
# sudo bash -c "cat /etc/ssh/sshd_config | sed 's/Port 22/Port 30/' | tee /etc/ssh/sshd_config"

# echo Installing application software
sudo apt-get install tmux python rsync zip unzip unrar xfce4 xfce4-power-manager xfce4-screenshooter evince pulseaudio cups cups-client ristretto gnome-screensaver scim scim-pinyin ttf-wqy-microhei ttf-wqy-zenhei fonts-inconsolata
# wget http://font.ubuntu.com/download/ubuntu-font-family-0.80.zip
# unzip ubuntu-font-family-0.80.zip
# mkdir ~/.fonts
# mv ubuntu-font-family-0.80/*.ttf ~/.fonts
# rm -rf ubuntu-font-family-0.80
# rm ubuntu-font-family-0.80.zip
# cp .tmux.conf ~

# Optional software, uncomment
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
sudo apt-get install -f
# sudo apt-get install latexmk latex-beamer
