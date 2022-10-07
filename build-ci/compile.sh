#!/bin/bash

BITCOIN_CONFIG_ALL=--disable-dependency-tracking --prefix=/home/travis/build/kiiglobal/kii-core/depends/x86_64-unknown-linux-gnu --bindir=/home/travis/build/kiiglobal/kii-core/out/bin --libdir=/home/travis/build/kiiglobal/kii-ore/out/lib

BITCOIN_CONFIG=--enable-zmq --enable-glibc-back-compat --enable-reduce-exports --enable-crash-hooks

../configure --cache-file=config.cache $BITCOIN_CONFIG_ALL $BITCOIN_CONFIG || ( cat config.log && false)
#make distdir VERSION=$BUILD_TARGET

#BUILD_TARGET=linux64
#cd kii-$BUILD_TARGET

cd ..

./autogen.sh
./configure --cache-file=../config.cache $BITCOIN_CONFIG_ALL $BITCOIN_CONFIG || ( cat config.log && false)
make $MAKEJOBS $GOAL || ( echo "Build failure. Verbose build follows." && make $GOAL V=1 ; false )
