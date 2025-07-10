#!/bin/bash

CURRENT_DIR=$PWD

OPENSSL_VERSION=r

if [ -n "$1" ]
 then
 OPENSSL_VERSION=$1
fi

PJSIP_DIR=$CURRENT_DIR/pjsip
OPENSSL_DIR=$CURRENT_DIR/openssl
OBJC_WRAPPER=$CURRENT_DIR/objc_wrapper

SOURCE=$OPENSSL_DIR/openssl-1_1_1$OPENSSL_VERSION/arm64/lib
DESTINATION=$PJSIP_DIR/pjproject/pjsip-apps/src/pjsua/ios

#SSL library set
set_ssl_lib() {
 if [ -f "$DESTINATION/libcrypto.a" ];
  then
    echo "File 'libcrypto.a' already exist at $DESTINATION ..."
  else
    echo "Moved 'libcrypto.a' at $DESTINATION ..."
    cp "$SOURCE/libcrypto.a" "$DESTINATION"
  fi
  
   if [ -f "$DESTINATION/libssl.a" ];
  then
    echo "File 'libssl.a' already exist at $DESTINATION ..."
  else
    echo "Moved 'libssl.a' at $DESTINATION ..."
    cp "$SOURCE/libssl.a" "$DESTINATION"
  fi
}

#OBJC Wrapper files set
set_objc_wrapper() {
 if [ -d "$DESTINATION/OnSolvePJSIPWrapper" ]
  then
    echo "Objc wrapper already exists...."
  else
    mkdir $DESTINATION/OnSolvePJSIPWrapper
    cp -a $OBJC_WRAPPER/. $DESTINATION/OnSolvePJSIPWrapper/
    echo "Created 'OnSolvePJSIPWrapper' folder at $DESTINATION ..."
 fi
 #cp -R path_to_source path_to_destination/
}

set_ssl_lib
set_objc_wrapper

    
