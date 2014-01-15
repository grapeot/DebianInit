.\setup-x86_64.exe -P sudo -P vim -P gvim -P openssh -P rsync -P gcc-g++ -P make -P wget -P curl -P dos2unix -P git -P tig -P zsh -s http://mirror.cc.columbia.edu/pub/software/cygwin/
cmd /c "set PATH=%PATH%;c:\cygwin64\bin; && zsh -i -c 'git clone https://github.com/grapeot/DebianInit.git; cd DebianInit; ./cygwin.sh'"
echo Don't forget to add the cygwin bin path to the system PATH.
