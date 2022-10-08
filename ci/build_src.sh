#!/usr/bin/env bash
#
# This script is executed inside the builder image

export LC_ALL=C

set -e

source ./ci/matrix.sh

unset CC; unset CXX
unset DISPLAY

export CCACHE_COMPRESS=${CCACHE_COMPRESS:-1}
export CCACHE_SIZE=${CCACHE_SIZE:-400M}

if [ "$PULL_REQUEST" != "false" ]; then test/lint/commit-script-check.sh $COMMIT_RANGE; fi

if [ "$CHECK_DOC" = 1 ]; then
    # TODO: Verify subtrees
    #test/lint/git-subtree-check.sh src/crypto/ctaes
    #test/lint/git-subtree-check.sh src/secp256k1
    #test/lint/git-subtree-check.sh src/univalue
    #test/lint/git-subtree-check.sh src/leveldb
    # TODO: Check docs (reenable after all Bitcoin PRs have been merged and docs fully fixed)
    #test/lint/check-doc.py
    # Check rpc consistency
    test/lint/check-rpc-mappings.py .
    # Run all linters
    test/lint/lint-all.sh
fi

ccache --max-size=$CCACHE_SIZE

if [ -n "$USE_SHELL" ]; then
  export CONFIG_SHELL="$USE_SHELL"
fi

BITCOIN_CONFIG_ALL="--disable-dependency-tracking --prefix=$BUILD_DIR/depends/$HOST --bindir=$OUT_DIR/bin --libdir=$OUT_DIR/lib"

( test -n "$USE_SHELL" && eval '"$USE_SHELL" -c "./autogen.sh"' ) || ./autogen.sh

rm -rf build-ci
mkdir build-ci
cd build-ci


#echo "I am here"
#pwd
#echo "BITCOIN_CONFIG_ALL=$BITCOIN_CONFIG_ALL | BITCOIN_CONFIG=$BITCOIN_CONFIG"
#env

#../configure --cache-file=config.cache $BITCOIN_CONFIG_ALL $BITCOIN_CONFIG || ( cat config.log && false)
#make distdir VERSION=$BUILD_TARGET
#cd kii-$BUILD_TARGET

NPROC=(nproc --all)

cd ..
#./autogen.sh
#./configure --cache-file=../config.cache $BITCOIN_CONFIG_ALL $BITCOIN_CONFIG || ( cat config.log && false)
#make $MAKEJOBS $GOAL || ( echo "Build failure. Verbose build follows." && make $GOAL V=1 ; false )

#echo --------------------------
#echo java version
#java -version
#java --version
#echo --------------------------


export SONAR_SCANNER_HOME=${TRAVIS_HOME}/.sonarscanner/sonar-scanner
echo --------------------------
echo "Dir TRAVIS_HOME"
echo ls -la ${TRAVIS_HOME}/
ls -lR / | grep -i sonar
echo -----------------------

exit 1

# Wraps the compilation with the Build Wrapper to generate configuration (used
# later by the SonarScanner) into the "bw-output" folder
echo This is env
env

### sonar cloud setup

#First, make sure we have java 11 sdk
apt-get install -y openjdk-11-jdk

#Get and install sonar-scanner in /opt

SONAR_URL="https://binaries.sonarsource.com/Distribution/sonar-scanner-cli"
SONAR_FILE="sonar-scanner-cli-4.7.0.2747"
SONAR_DIR="sonar-scanner-4.7.0.2747"

rm -rf /opt/sonar-scanner*

mkdir -p /opt
pushd /opt
wget $SONAR_URL/$SONAR_FILE.zip
unzip $SONAR_FILE.zip

export PATH=$PATH:/opt/$SONAR_DIR/bin
echo --------- Done installing SonarCloud binaries -------------



echo ----------------------------
echo About to run SonarCloud make Wrapper
echo ----------------------------
build-wrapper-linux-x86-64 --out-dir bw-output make $MAKEJOBS $GOAL || ( echo "Build failure. Verbose build follows." && make $GOAL V=1 ; false )

# And finally run the SonarCloud analysis - read the "sonar-project.properties"
# file to see the specific configuration
echo About to run sonar-scanner
echo ----------------------------
sonar-scanner -Dsonar.cfamily.build-wrapper-output=bw-output
