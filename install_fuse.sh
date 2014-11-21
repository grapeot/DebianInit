if [-a ~/.passwd-s3fs ]; then
    # first run
    sudo apt-get remove fuse
    sudo apt-get install build-essential libcurl4-openssl-dev libxml2-dev mime-support

    wget http://downloads.sourceforge.net/project/fuse/fuse-2.X/2.9.3/fuse-2.9.3.tar.gz
    tar xzf fuse-2.9.3.tar.gz
    pushd fuse-2.9.3
    ./configure --prefix=/usr/local
    make -j && sudo make install
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    ldconfig
    modprobe fuse
    popd

    wget https://s3fs.googlecode.com/files/s3fs-1.74.tar.gz
    tar xzf s3fs-1.74.tar.gz
    pushd s3fs-1.74
    ./configure --prefix=/usr/local
    make && sudo make install

    echo AWS_ACCESS_KEY_ID:AWS_SECRET_ACCESS_KEY > ~/.passwd-s3fs
    chmod 600 ~/.passwd-s3fs
    mkdir /tmp/cache
    mkdir ~/s3mnt
    chmod 777 /tmp/cache ~/s3mnt

else
    # second run
    s3fs -o use_cache=/tmp/cache grapeot-main /home/ubuntu/s3mnt
fi
