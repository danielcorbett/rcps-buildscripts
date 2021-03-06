#!/usr/bin/env bash

###############################################
# Installing 
#
# by Owain Kenway, 2019
#
set -e

for i in ${includes_dir:=$(dirname $0 2>/dev/null)/includes}/{module_maker,require}_inc.sh; do . $i; done

require gcc-libs/4.9.2

NAME=${NAME:-NetLogo}
VERSION=${VERSION:-6.1.0}
INSTALL_PREFIX=${INSTALL_PREFIX:-/shared/ucl/apps/$NAME/$VERSION/}
MD5=${MD5:-1f69450af8d25aa3e833a37d144df73b}

SRC_ARCHIVE=${SRC_ARCHIVE:-https://ccl.northwestern.edu/netlogo/${VERSION}/NetLogo-${VERSION}-64.tgz}


rm -rf ${INSTALL_PREFIX} # Clear old installs
mkdir -p ${INSTALL_PREFIX}

cd ${INSTALL_PREFIX}

wget $SRC_ARCHIVE
archive=$(basename "${SRC_ARCHIVE}")

md5sum -c <<< "$MD5 $archive"

tar -xvf $archive

mv "${NAME} ${VERSION}" tmp # Spaces in filenames :(
mv tmp/* .
rm -rf tmp

# We need to remove all binaries.
rm -f Behaviorsearch HubNetClient libpackager.so NetLogo NetLogo3D NetLogoLogging
rm -rf runtime

# Create scripts to launch netlogo from the headless one as a model.
cp netlogo-headless.sh netlogo.sh
ln -s netlogo.sh NetLogo
sed -i.bak 's|org.nlogo.headless.Main|-jar ${BASE_DIR}/app/netlogo-6.1.0.jar|g' netlogo.sh
sed -i.bak 's|-Dfile.encoding=UTF-8|-Dfile.encoding=UTF-8 -Dnetlogo.models.dir=${BASE_DIR}/app/models|g' netlogo-headless.sh
sed -i.bak 's|-Dfile.encoding=UTF-8|-Dfile.encoding=UTF-8 -Dnetlogo.models.dir=${BASE_DIR}/app/models|g' netlogo.sh

rm *.bak
