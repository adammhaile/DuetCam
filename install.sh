#!/usr/bin/env bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# apt-get -y install git cmake
# apt-get -y install libjpeg62-turbo-dev
# apt-get -y install libjpeg8-dev
# apt-get -y --no-install-recommends install imagemagick ffmpeg libv4l-dev

TMP_DIR=$(mktemp -d -t ci-XXXXXXXXXX)
git clone https://github.com/jacksonliam/mjpg-streamer.git ${TMP_DIR}

pushd ${TMP_DIR}
mv mjpg-streamer-experimental/* .

# As said in Makefile, it is just a wrapper around CMake.
# To apply -j option, we have to unwrap it.
MJPG_STREAMER_BUILD_DIR=_build
[ -d ${MJPG_STREAMER_BUILD_DIR} ] || (mkdir ${MJPG_STREAMER_BUILD_DIR} && \
chown pi:pi ${MJPG_STREAMER_BUILD_DIR})
[ -f ${MJPG_STREAMER_BUILD_DIR}/Makefile ] || (cd ${MJPG_STREAMER_BUILD_DIR} && \
cmake -DCMAKE${MJPG_STREAMER_BUILD_DIR}_TYPE=Release ..)

make -j $(nproc) -C ${MJPG_STREAMER_BUILD_DIR}

INSTALL_DIR=/usr/local/bin/mjpg-streamer/
mkdir -p ${INSTALL_DIR}
cp -f ${MJPG_STREAMER_BUILD_DIR}/mjpg_streamer ${INSTALL_DIR}
find ${MJPG_STREAMER_BUILD_DIR} -name "*.so" -type f -exec cp -f {} ${INSTALL_DIR} \;


# create custom web folder and add a minimal index.html to it
rm -rf ${INSTALL_DIR}www-webcamd
mkdir -p ${INSTALL_DIR}www-webcamd
cat <<EOT >> ${INSTALL_DIR}www-webcamd/index.html
<html>
<head><title>mjpg_streamer test page</title></head>
<body>
<h1>Snapshot</h1>
<p>Refresh the page to refresh the snapshot</p>
<img src="./?action=snapshot" alt="Snapshot">
<h1>Stream</h1>
<img src="./?action=stream" alt="Stream">
</body>
</html>
EOT

popd

CONFIG_DIR=/home/pi/.config/
mkdir -p ${CONFIG_DIR}
cp webcamd.txt ${CONFIG_DIR}
chown pi:pi ${CONFIG_DIR}/webcamd.txt

mkdir -p /root/bin/
cp webcamd /root/bin/webcamd
cp webcamd.service /etc/systemd/system/webcamd.service

systemctl daemon-reload
systemctl enable webcamd.service
systemctl start webcamd.service
