# set base os
FROM ubuntu:12.04
ENV DEBIAN_FRONTEND noninteractive
# Set correct environment variables
ENV HOME /root
mkdir -p /root/debout /root/patches

VOLUME /root/debout
VOLUME /root/patches

ADD patches /root/patches/

# Install checkinstall 

RUN apt-get update && \

apt-get install build-essential automake autoconf libtool pkg-config libcurl4-openssl-dev intltool libxml2-dev libgtk2.0-dev libnotify-dev libglib2.0-dev libevent-dev checkinstall -y

# Install KODI build dependencies

RUN apt-get update && \

apt-get install autopoint bison ccache cmake curl cvs default-jre fp-compiler gawk gdc gettext git-core gperf libasound2-dev libass-dev libavcodec-dev libavfilter-dev libavformat-dev libavutil-dev libbluetooth-dev libboost-dev libboost-thread-dev libbz2-dev libcap-dev libcdio-dev libcec-dev libcec1 libcrystalhd-dev libcrystalhd3 libcurl3 libcurl4-gnutls-dev libcwiid-dev libcwiid1 libdbus-1-dev libenca-dev libflac-dev libfontconfig-dev libfreetype6-dev libfribidi-dev libglew-dev libiso9660-dev libjasper-dev libjpeg-dev libltdl-dev liblzo2-dev libmad0-dev libmicrohttpd-dev libmodplug-dev libmp3lame-dev libmpeg2-4-dev libmpeg3-dev libmysqlclient-dev libnfs-dev libogg-dev libpcre3-dev libplist-dev libpng-dev libpostproc-dev libpulse-dev libsamplerate-dev libsdl-dev libsdl-gfx1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libshairport-dev libsmbclient-dev libsqlite3-dev libssh-dev libssl-dev libswscale-dev libtiff-dev libtinyxml-dev libudev-dev libusb-dev libva-dev libva-egl1 libva-tpi1 libvdpau-dev libvorbisenc2 libxmu-dev libxrandr-dev libxrender-dev libxslt1-dev libxt-dev libyajl-dev mesa-utils nasm pmount python-dev python-imaging python-sqlite swig unzip yasm zip zlib1g-dev libltdl-dev -y

# Pull kodi source from git and apply any patches
# Edit this section for branch, configure enables/disables  and patch etc.....

RUN apt-get install -y software-properties-common python-software-properties && \
add-apt-repository ppa:team-xbmc/ppa && \
apt-get update && \
apt-get install -y libbluray-dev libbluray1 && \
add-apt-repository --remove ppa:team-xbmc/ppa

RUN wget http://pkgs.fedoraproject.org/lookaside/pkgs/taglib/taglib-1.8.tar.gz/dcb8bd1b756f2843e18b1fdf3aaeee15/taglib-1.8.tar.gz && \
tar xzf taglib-1.8.tar.gz && \
cd taglib-1.8 && \
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_RELEASE_TYPE=Release . && \
make && \
make install

# Main git source
RUN git clone https://github.com/topfs2/xbmc.git

# mv patch to xbmc folder

RUN cd xbmc && \
mv /root/patches/5071.patch . && \

# checkout branch/tag

git checkout helix_headless && \

# Apply patch(s)

# git apply 5071.patch && \

# Configure, make, clean.
./bootstrap && \
./configure \
--disable-libcec \
--prefix=/opt/kodi-server && \
make

RUN cd xbmc && \
checkinstall -y --fstrans=no --install=yes --pkgname=sparkly-kodi-headless --pkgversion="`date +%Y%m%d`.`git rev-parse --short HEAD`"

ADD startup/movedeb.sh /root/movedeb.sh
RUN chmod +x /root/movedeb.sh

ENTRYPOINT ["/root/movedeb.sh"]
