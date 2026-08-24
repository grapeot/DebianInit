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
./setup_debian.sh | tee logs
```

# Otherplatforms

## Ubuntu

Idempotent CLI bootstrap (`setup_ubuntu.sh`). Safe to re-run. Does not change the SSH port.

Python for development is **uv** (same installer as Mac). Distro `python3` is left alone; do not `pip install` into it.

```
cd DebianInit
./setup_ubuntu.sh
```

## cygwin

Also supports cygwin for a fast linux-like environment. First download the 64bit installer from cygwin website, and then download the `cgywin.cmd` to the same folder. Double click to run. [`chocolatey`](https://chocolatey.org/) will be installed as the package management system.
