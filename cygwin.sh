echo Make sure you have installed vim, zsh, git, wget and dos2unix
while true; do
    read -p "Ready to continue (y/n): " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
done

# Configure development environment
# shell environment...
wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
pushd ~
git clone https://github.com/rupa/z
popd
# .zshrc
cat << EOF >> ~/.zshrc
export PATH=$PATH:/usr/local/bin:/usr/bin:/bin:/sbin
alias ls='ls --color=auto -h'
alias ll='ls -l'
alias gs='git status'
alias gm='git commit -m'
alias gma='git commit -a -m'
alias gc='git checkout'
alias open='xdg-open'
alias rm='trash-put'
set -o vi
setenv DISPLAY localhost:0
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
git config --global color.ui auto
# ssh configuration (won't take effect until restart)
cat /etc/sshd_config | sed 's/Port 22/Port 30/' | tee /etc/ssh/sshd_config

# install other windows programs
cd ..
wget http://downloads.sourceforge.net/sevenzip/7z920-x64.msi
wget http://download.filezilla-project.org/FileZilla_3.7.3_win32-setup.exe
wget https://www.dropbox.com/download?plat=win -O dropbox.exe
iexplore 'http://google.com/chrome/'
explorer .
