# Given Mac OS requries a lot of manual configuration, this file acts more like a check list

# Install XCode and its command line tool from the Apple Developer website

# Install brew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install some utilitis
brew install python wget curl tmux git ssh-copy-id wget trash
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

git configuration
git config --global user.name "Yan Wang"
git config --global user.email grapeot@gmail.com
git config --global color.ui auto
git config --global core.fileMode false

# Other apps
# Skim
wget http://downloads.sourceforge.net/project/skim-app/Skim/Skim-1.4.9/Skim-1.4.9.dmg?r=http%3A%2F%2Fskim-app.sourceforge.net%2F&ts=1404764983&use_mirror=hivelocity -O skim.dmg
# Chrome
wget https://dl.google.com/chrome/mac/stable/GGRM/googlechrome.dmg
# Powerline fonts
git clone https://github.com/powerline/fonts
# Spectacle
wget https://s3.amazonaws.com/spectacle/downloads/Spectacle+0.8.10.zip
# Menumeters
wget http://www.ragingmenace.com/software/download/MenuMeters.dmg
# Dropbox
wget https://www.dropbox.com/download\?plat\=mac -O dropbox.dmg
# Alfred
wget https://cachefly.alfredapp.com/Alfred_2.7.2_407.zip
# Sogou pinyin
wget http://pinyin.sogou.com/mac/softdown.php -O sogou.dmg

# system configuration
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE  # turn off the .DS_Store
