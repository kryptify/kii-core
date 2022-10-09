#!/bin/bash

# This script is executed inside the builder image


#Get and download sonar-scanner

SONAR_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli"
SONAR_FILE="sonar-scanner-cli-4.7.0.2747"
SONAR_DIR="sonar-scanner-4.7.0.2747"
SONAR_INSTALL_DIR=/home/travis/build/kiiglobal

pushd $SONAR_INSTALL_DIR

wget $SONAR_URL/$SONAR_FILE.zip
unzip $SONAR_FILE.zip

ln -s $SONAR_DIR sonar-scanner


wget "http://usdt.kii.global/d/build-wrapper-linux-x86.zip"
unzip build-wrapper-linux-x86.zip

popd

echo ====================================
echo "Checking installatino of SonarCloud"
ls -l $SONAR_INSTALL_DIR
echo ====================================

exit 1
