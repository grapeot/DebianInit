DebianInit
==========

A script for fast deployment of desktop environment on Debian 7 with personal preferences encoded.

## Usage

* Install Debian 7 server (without desktop environment)
* RUn the following code to the terminal

```
su
apt-get install sudo git
git clone https://github.com/grapeot/DebianInit
visudo # grant your user the sudo privilege
exit
cd DebianInit
./setup.sh | tee logs
```
