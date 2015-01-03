# set base os
FROM ubuntu:12.04
ENV DEBIAN_FRONTEND noninteractive
# Set correct environment variables
ENV HOME /root
RUN mkdir -p /root/debout /root/patches

VOLUME /root/debout
VOLUME /root/patches

ADD patches /root/patches/

# Install checkinstall 

RUN apt-get update && \

apt-get install build-essential automake autoconf libtool pkg-config libcurl4-openssl-dev intltool libxml2-dev libgtk2.0-dev libnotify-dev libglib2.0-dev libevent-dev checkinstall -y

# Install KODI build dependencies

RUN apt-get update && \

apt-get install -y wget software-properties-common python-software-properties -y

# Pull kodi source from git and apply any patches
# Edit this section for branch, configure enables/disables  and patch etc.....


RUN add-apt-repository ppa:team-xbmc/ppa && \
add-apt-repository ppa:team-xbmc/xbmc-ppa-build-depends && \
apt-get update && \
apt-get build-dep kodi -y

RUN wget http://pkgs.fedoraproject.org/lookaside/pkgs/taglib/taglib-1.8.tar.gz/dcb8bd1b756f2843e18b1fdf3aaeee15/taglib-1.8.tar.gz && \
tar xzf taglib-1.8.tar.gz && \
cd taglib-1.8 && \
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_RELEASE_TYPE=Release . && \
make && \
make install

# Main git source
RUN git clone https://github.com/xbmc/xbmc.git

# mv patch to xbmc folder

RUN cd xbmc && \
mv /root/patches/5071.patch . && \

# checkout branch/tag

git checkout 14.0-Helix && \

# Apply patch(s)

git apply 5071.patch && \

# Configure, make, clean.
./bootstrap && \
./configure \
--enable-nfs \
--enable-upnp \
--enable-ssh \
--enable-libbluray \
--disable-debug \
--disable-vdpau \
--disable-vaapi \
--disable-crystalhd \
--disable-vdadecoder \
--disable-vtbdecoder \
--disable-openmax \
--disable-joystick \
--disable-rsxs \
--disable-projectm \
--disable-rtmp \
--disable-airplay \
--disable-airtunes \
--disable-dvdcss \
--disable-optical-drive \
--disable-libusb \
--disable-libcec \
--disable-libmp3lame \
--disable-libcap \
--disable-udev \
--disable-libvorbisenc \
--disable-asap-codec \
--disable-afpclient \
--disable-goom \
--disable-fishbmc \
--disable-spectrum \
--disable-waveform \
--disable-avahi \
--disable-non-free \
--disable-texturepacker \
--disable-pulse \
--disable-dbus \
--disable-alsa \
--disable-hal \
--prefix=/opt/kodi-server && \
make

RUN cd xbmc && \
checkinstall -y --fstrans=no --install=yes --pkgname=sparkly-kodi-headless --pkgversion="`date +%Y%m%d`.`git rev-parse --short HEAD`"

ADD startup/movedeb.sh /root/movedeb.sh
RUN chmod +x /root/movedeb.sh

ENTRYPOINT ["/root/movedeb.sh"]
