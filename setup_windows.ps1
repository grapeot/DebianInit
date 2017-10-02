$wc = New-Object System.Net.WebClient
$wc.DownloadFile('https://www.cygwin.com/setup-x86_64.exe', 'setup-x86_64.exe')
$wc.DownloadFile('https://raw.githubusercontent.com/grapeot/DebianInit/master/cygwin.sh', 'cygwin.sh')


# We use windows version for better compatibility with VSOnline and https.
$wc.DownloadFile('https://chocolatey.org/install.ps1', 'installChocolatey.ps1')
.\installChocolatey.ps1
choco install -y git

# Install cygwin
.\setup-x86_64.exe -P vim -P openssh -P rsync -P gcc-g++ -P make -P wget -P curl -P dos2unix -P tig -P zsh -P tmux -s http://mirror.cc.columbia.edu/pub/software/cygwin/ | Out-Null
c:\cygwin64\bin\zsh.exe -i -c "c:/cygwin64/bin/mkpasswd -c | c:/cygwin64/bin/sed 's/bash/zsh/' | c:/cygwin64/bin/sed 's/\/home/\/cygdrive\/c\/Users/' | c:/cygwin64/bin/tee /etc/passwd"
cmd /c "set PATH=%PATH%;c:\cygwin64\bin; && zsh -i -c './cygwin.sh'"
echo "Don't forget to add the cygwin bin path to the system PATH."

# Install other dev tools
choco install -y 7zip vim python3
$wc.DownloadFile('https://bootstrap.pypa.io/get-pip.py', 'get-pip.py')
C:\Python36\python.exe .\get-pip.py
rm .\installChocolatey.ps1
rm .\get-pip.py

# Fix the windows version of .dotfile
# To make symbolic links, we need to import an API from kernel32.dll
# https://learn-powershell.net/2013/07/16/creating-a-symbolic-link-using-powershell/
Add-Type @"
using System;
using System.Runtime.InteropServices;
 
namespace mklink
{
    public class symlink
    {
        [DllImport("kernel32.dll")]
        public static extern bool CreateSymbolicLink(string lpSymlinkFileName, string lpTargetFileName, int dwFlags);
    }
}
"@
[mklink.symlink]::CreateSymbolicLink('c:/Users/grapeot/.vim',"c:/Users/grapeot/.dotfiles/.vim",1)
[mklink.symlink]::CreateSymbolicLink('c:/Users/grapeot/.vimrc',"c:/Users/grapeot/.dotfiles/.vimrc",0)
[mklink.symlink]::CreateSymbolicLink('c:/Users/grapeot/.zshrc',"c:/Users/grapeot/.dotfiles/.zshrc",0)
