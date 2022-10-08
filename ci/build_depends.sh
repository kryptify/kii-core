#!/usr/bin/env bash
#
# This script is executed inside the builder image

export LC_ALL=C

set -e

source ./ci/matrix.sh

unset CC; unset CXX
unset DISPLAY

mkdir -p $CACHE_DIR/depends
mkdir -p $CACHE_DIR/sdk-sources

ln -s $CACHE_DIR/depends depends/built
ln -s $CACHE_DIR/sdk-sources depends/sdk-sources

mkdir -p depends/SDKs

if [ -n "$OSX_SDK" ]; then
  if [ ! -f depends/sdk-sources/MacOSX${OSX_SDK}.sdk.tar.gz ]; then
    curl --location --fail $SDK_URL/MacOSX${OSX_SDK}.sdk.tar.gz -o depends/sdk-sources/MacOSX${OSX_SDK}.sdk.tar.gz
  fi
  if [ -f depends/sdk-sources/MacOSX${OSX_SDK}.sdk.tar.gz ]; then
    tar -C depends/SDKs -xf depends/sdk-sources/MacOSX${OSX_SDK}.sdk.tar.gz
  fi
fi

apt-get install -y openjdk-11-jdk


echo ===============================
echo java version
java -version
echo ===============================
echo Buscando el bendito build-wrapper-linux-x86-64
which build-wrapper-linux-x86-64
echo ----------------------------------

exit 1
make $MAKEJOBS -C depends HOST=$HOST $DEP_OPTS > /dev/null
