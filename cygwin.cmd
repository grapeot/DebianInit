setup-x86_64.exe -P vim -P openssh -P rsync -P gcc-g++ -P make -P wget -P curl -P dos2unix -P git -P tig -P zsh -P tmux -s http://mirror.cc.columbia.edu/pub/software/cygwin/
pause

c:\cygwin64\bin\zsh.exe -i -c "c:/cygwin64/bin/mkpasswd -c | c:/cygwin64/bin/sed 's/bash/zsh/' | c:/cygwin64/bin/sed 's/\/home/\/cygdrive\/c\/Users/' | c:/cygwin64/bin/tee /etc/passwd"
cmd /c "set PATH=%PATH%;c:\cygwin64\bin; && zsh -i -c 'git clone https://github.com/grapeot/DebianInit.git; cd DebianInit; ./cygwin.sh'"
echo Don't forget to add the cygwin bin path to the system PATH.

:: install chocolatey
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
