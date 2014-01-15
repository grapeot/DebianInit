DebianInit
==========

A script for fast deployment of desktop environment on Debian 7 with personal preferences encoded.

## Usage

* Install Debian 7 server (without desktop environment)
* Run the following code to the terminal

```
su
apt-get install sudo git
git clone https://github.com/grapeot/DebianInit
visudo # grant your user the sudo privilege
exit
cd DebianInit
./setup.sh | tee logs
```

# Otherplatforms

## ec2-ubuntu

Also supports ubuntu on ec2 for scientific computing. Usage similar to debian.

## cygwin

Also supports cygwin for a fast linux-like environment. First download the 64bit installer from cygwin website, and then download the `cgywin.cmd` to the same folder. Double to run.
