# echo Please install vim and configure sudo manually
# su 

# echo Configure sources
# sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
# sudo bash -c "cat /etc/apt/sources.list | sed 's/wheezy /unstable /g' | sed 's/main/main contrib non-free/' | tee /etc/apt/sources.list"
# sudo apt-get update

# echo Configure development environment
# sudo apt-get install zsh git tig build-essential wget curl
# echo Shell environment...
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
echo vim configuration...
# git clone https://gist.github.com/4576917.git
cat 4576917/vimrc | sed 's/consolas:h16/Inconsolata\ 14/' > ~/.vimrc
mkdir ~/.vim
cd ~/.vim

cd ~

echo git configuration
git config --global user.name "Yan Wang"
git config --global user.email grapeot@gmail.com

# echo Installing application software
