#!/bin/bash

OPENSSL_VERSION=r
PJSIP_VERSION=2.12.1
TARGET_ARCH=arm64
MIN_IOS=11.0
FORCE_BUILD=false

sudo chmod +x build.sh

if [ -n "$1" ]
 then
 OPENSSL_VERSION=$1
fi

if [ -n "$2" ]
 then
 PJSIP_VERSION=$2
fi

if [ -n "$3" ]
 then
 TARGET_ARCH=$3
fi

if [ -n "$4" ]
 then
 MIN_IOS=$4
fi

./openssl.sh $OPENSSL_VERSION $FORCE_BUILD
./pjsip.sh $PJSIP_VERSION $TARGET_ARCH $MIN_IOS $OPENSSL_VERSION
./objc_wrapper.sh $OPENSSL_VERSION

    
