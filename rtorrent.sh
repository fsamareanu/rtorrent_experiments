#!/bin/bash

# ==> VARIABLES <==
# Software Versions
LIBTORRENT_VER="0.13.8"
RTORRENT_VER="0.9.8"
#XMLRPC_VER="1.39.12"
XMLRPC_VER="1.39.13"
PKG_RELEASE="3"
PREFIX="/usr"
CFLAGS="-march=native -pipe -O2 -fomit-frame-pointer${CFLAGS:+ }${CFLAGS}"
export CFLAGS

# URLs
LIBTORRENT_URL="http://rtorrent.net/downloads/libtorrent-$LIBTORRENT_VER.tar.gz"
RTORRENT_URL="http://rtorrent.net/downloads/rtorrent-$RTORRENT_VER.tar.gz"
XMLRPC_URL="https://sourceforge.net/projects/xmlrpc-c/files/Xmlrpc-c%20Super%20Stable/$XMLRPC_VER/xmlrpc-c-$XMLRPC_VER.tgz/download"

# Misc.
SRC_DIR="$HOME/src/build/rtorrent/source"
DEB_DIR="$HOME/src/build/rtorrent/binaries"
PATCH_DIR="$HOME/src/build/rtorrent/vanilla-patches"
PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_PATH

# ==> MAIN PROGRAM <==
set -e

# Remove old versions
#sudo dpkg -P xmlrpc-c
#sudo dpkg -P libtorrent
#sudo dpkg -P rtorrent
#sleep 3


# Create src and build dirs.
if [ ! -d $SRC_DIR ]; then
	mkdir -p $SRC_DIR
fi

if [ ! -d $DEB_DIR ]; then
	mkdir -p $DEB_DIR
fi


# Build XMLRPC.
cd $SRC_DIR
if [ ! -f $SRC_DIR/xmlrpc-c-$XMLRPC_VER.tgz ]; then
	wget -O xmlrpc-c-$XMLRPC_VER.tgz $XMLRPC_URL
fi
if [ ! -d $SRC_DIR/xmlrpc-c-$XMLRPC_VER ]; then
	tar xvf xmlrpc-c-$XMLRPC_VER.tgz
fi
cd $SRC_DIR/xmlrpc-c-$XMLRPC_VER
./configure --prefix="$PREFIX" --enable-libxml2-backend --disable-libwww-client --disable-wininet-client --disable-abyss-server --disable-cgi-server --disable-cplusplus
make -j$(nproc)
sudo checkinstall -D --pkgrelease="$PKG_RELEASE" --install=no -y
sleep 3
cp $SRC_DIR/xmlrpc-c-$XMLRPC_VER/xmlrpc-c_"$XMLRPC_VER"-"$PKG_RELEASE"_amd64.deb $DEB_DIR
sudo rm -rf $SRC_DIR/xmlrpc-c-$XMLRPC_VER


# Build Libtorrent.
cd $SRC_DIR
if [ ! -f $SRC_DIR/libtorrent-$LIBTORRENT_VER.tar.gz ]; then
	wget $LIBTORRENT_URL
fi
if [ ! -d $SRC_DIR/libtorrent-$LIBTORRENT_VER ]; then
	tar xvzf libtorrent-$LIBTORRENT_VER.tar.gz
	cd $SRC_DIR/libtorrent-$LIBTORRENT_VER
	patch -p1 < $PATCH_DIR/01-lt-udns.patch
	patch -p1 < $PATCH_DIR/02-lt-calomel_disconnect_clients.patch
	patch -p1 < $PATCH_DIR/03-lt-calomel_tracker_announce.patch
	patch -p1 < $PATCH_DIR/04-lt-ps_all-better-bencode-errors_all.patch
fi
cd $SRC_DIR/libtorrent-$LIBTORRENT_VER
./autogen.sh
./configure --prefix="$PREFIX" --disable-debug --with-posix-fallocate
make -j$(nproc)
sudo checkinstall -D --pkgrelease="$PKG_RELEASE" --install=no -y
sleep 3
cp $SRC_DIR/libtorrent-$LIBTORRENT_VER/libtorrent_"$LIBTORRENT_VER"-"$PKG_RELEASE"_amd64.deb $DEB_DIR
sudo rm -rf $SRC_DIR/libtorrent-$LIBTORRENT_VER


# Build rTorrent.
cd $SRC_DIR
if [ ! -f $SRC_DIR/rtorrent-$RTORRENT_VER.tar.gz ]; then
	wget $RTORRENT_URL
fi
if [ ! -d $SRC_DIR/rtorrent-$RTORRENT_VER ]; then
	tar xvzf rtorrent-$RTORRENT_VER.tar.gz
	cd $SRC_DIR/rtorrent-$RTORRENT_VER
	patch -p1 < $PATCH_DIR/01-rt-calomel_maxUnchoked.patch
fi
cd $SRC_DIR/rtorrent-$RTORRENT_VER
./autogen.sh
./configure --prefix="$PREFIX" --with-xmlrpc-c
make -j$(nproc)
sudo checkinstall -D --pkgrelease="$PKG_RELEASE" --install=no -y
sleep 3
cp $SRC_DIR/rtorrent-$RTORRENT_VER/rtorrent_"$RTORRENT_VER"-"$PKG_RELEASE"_amd64.deb $DEB_DIR
sudo rm -rf $SRC_DIR/rtorrent-$RTORRENT_VER
#sudo ldconfig
