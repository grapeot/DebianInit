# Install XCode and its command line tool from the Apple Developer website

echo "\!\!\!PLEASE FIRST INSTALL XCODE AND ITS COMMANDLINE TOOL BEFORE RUNNING THIS SCRIPT\!\!\!"
echo "OTHERWISE A LOT OF THINGS WON'T WORK"

# Install brew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install some utilitis
brew install python wget curl tmux git ssh-copy-id wget trash ssh-copy-id
sudo easy_install pip
brew install macvim --env-std --override-system-vim

# Scientific Development Environment
pip install numpy scipy matplotlib

cd ~

# oh-my-zsh and z
curl -L http://install.ohmyz.sh | sh
git clone https://github.com/rupa/z

# .dotfiles and deploy
git clone --recursive https://github.com/grapeot/.dotfiles
./.dotfiles/deploy_mac.sh

cd debianinit

# git configuration
git config --global user.name "Yan Wang"
git config --global user.email grapeot@outlook.com
git config --global color.ui auto
git config --global core.fileMode false
git config --global push.default simple

# Other apps
# Powerline fonts
git clone https://github.com/powerline/fonts
# Spectacle
wget https://s3.amazonaws.com/spectacle/downloads/Spectacle+0.8.10.zip

# system configuration
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE  # turn off the .DS_Store
