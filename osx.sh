# Given Mac OS requries a lot of manual configuration, this file acts more like a check list

# Install XCode and its command line tool from the Apple Developer website

# Install brew
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

# Install some utilitis
brew install python wget curl tmux git
brew install vim --with-python --with-ruby --with-perl
brew install macvim --env-std --override-system-vim

# Scientific Development Environment
pip install numpy scipy matplotlib

# oh-my-zsh and z
curl -L http://install.ohmyz.sh | sh
pushd ~
git clone https://github.com/rupa/z
popd

# .dotfiles and deploy
pushd ~
git clone --recursive https://github.com/.dotfiles
./.dotfiles/deploy_mac.sh
popd

# git configuration
git config --global user.name "Yan Wang"
git config --global user.email grapeot@gmail.com
git config --global color.ui auto

# Other apps
# Skim
wget http://downloads.sourceforge.net/project/skim-app/Skim/Skim-1.4.9/Skim-1.4.9.dmg?r=http%3A%2F%2Fskim-app.sourceforge.net%2F&ts=1404764983&use_mirror=hivelocity
# Chrome
wget https://dl.google.com/chrome/mac/stable/GGRM/googlechrome.dmg
