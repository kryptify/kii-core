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

echo ===============================
echo Testingx wrapper and sonar-scanner TRAVIS_HOME=$TRAVIS_HOME
ls -la /opt

echo --------------------- -----------------

#$SONAR_SCANNER_HOME/bin/sonar-scanner
find / -name build-wrapper-linux-x86-64 
find / -name sonar-scanner
echo ----------------------------------

exit 1
make $MAKEJOBS -C depends HOST=$HOST $DEP_OPTS > /dev/null
