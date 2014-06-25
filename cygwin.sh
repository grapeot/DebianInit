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
# .dotfiles
pushd ~
git clone --recursive https://github.com/grapeot/.dotfiles
# .zshrc
ln -s .dotfiles/.zshrc .zshrc
# .vimrc
ln -s .dotfiles/.vim .vim
ln -s .dotfiles/.vimrc .vimrc
cat ~/.vimrc | sed 's/consolas:h16/Inconsolata\\ 14/' > ~/.vimrc # patch for debian GUI
# .tmux.conf
ln -s .dotfiles/.tmux.conf .tmux.conf
popd
# git configuration
git config --global user.name "Yan Wang"
git config --global user.email grapeot@gmail.com
git config --global color.ui auto
# ssh configuration (won't take effect until restart)
cat /etc/sshd_config | sed 's/Port 22/Port 30/' | tee /etc/ssh/sshd_config 
