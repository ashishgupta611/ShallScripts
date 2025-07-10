#!/bin/bash
#https://www.pjsip.org/download.htm

########################################################################
#Variables
CURRENT_DIR=$PWD
echo "CURRENT_DIR=$PWD"

VERSION=2.15.1
TARGET_ARCH=arm64
MIN_IOS=11.0
OPENSSL_VERSION=r

if [ -n "$1" ]
 then
 VERSION=$1
fi

if [ -n "$2" ]
 then
 TARGET_ARCH=$2
fi

if [ -n "$3" ]
 then
 MIN_IOS=$3
fi

if [ -n "$4" ]
 then
 OPENSSL_VERSION=$4
fi

ROOT_DIR=pjsip
ZIP_NAME=pjproject-$VERSION
PROJECT_DIR=pjproject

sudo chmod +x pjsip.sh

create_root_dir()
{
if [ -d "$CURRENT_DIR/$ROOT_DIR" ]
 then
    echo "Directory '$ROOT_DIR' already exists."
 else
    echo "Created '$ROOT_DIR' directory."
    mkdir $ROOT_DIR
fi
}

download_zip() {
 cd $ROOT_DIR

 if [ -f "$CURRENT_DIR/$ROOT_DIR/$ZIP_NAME.zip" ];
  then
    echo "$ZIP_NAME.zip is already exist"
 else
    echo "$ZIP_NAME.zip does not exist, downloading PJSip project zip file...."
    sudo wget https://github.com/pjsip/pjproject/archive/refs/tags/2.12.1.zip --output-document=$ZIP_NAME.zip
  fi
}

check_lib_unzip() {
 if [ -d "$CURRENT_DIR/$ROOT_DIR/$PROJECT_DIR" ]
  then
    echo "'$PROJECT_DIR' already exists ...."
  else
   echo "'$PROJECT_DIR' does not exists so unzipping new project...."
   unzip_lib
  fi
}

unzip_lib() {
   if [ -d "$CURRENT_DIR/$ROOT_DIR/$ZIP_NAME" ]
    then
     rm -r dirname $CURRENT_DIR/$ROOT_DIR/$ZIP_NAME
   fi
   
   if [ -d "$CURRENT_DIR/$ROOT_DIR/$PROJECT_DIR" ]
    then
      rm -r dirname $CURRENT_DIR/$ROOT_DIR/$PROJECT_DIR
   fi
  
  if [ -r "$CURRENT_DIR/$ROOT_DIR/$ZIP_NAME.zip" ]
   then
     echo "##### ****** Unziping Started...####'$ZIP_NAME'.zip file.....****** #########"
     unzip $ZIP_NAME.zip
     echo "#####  ****** Unziping Completed. ****** #############"
  fi
}

check_lib_rename() {
 if [ -d "$CURRENT_DIR/$ROOT_DIR/$PROJECT_DIR" ]
  then
    echo "'$PROJECT_DIR' already exists ...."
  else
   echo "'$PROJECT_DIR' does not so renaming the unzip project...."
   rename_lib_dir
  fi
}

rename_lib_dir() {
 if [ -d "$CURRENT_DIR/$ROOT_DIR/$ZIP_NAME" ]
  then
   echo "Renaming $ZIP_NAME into $PROJECT_DIR"
   mv $ZIP_NAME $PROJECT_DIR
  else
   echo "Directory '$ZIP_NAME' does not exists."
  fi
}

check_build_lib() {
 DESTINATION=$CURRENT_DIR/$ROOT_DIR/$PROJECT_DIR/pjsip-apps/src/pjsua/ios
 
  if [ -f "$DESTINATION/libcrypto.a" ];
  then
    echo "PJSip already built earlier ..."
  else
    echo "'libcrypto.a' not found at $DESTINATION..... Building PJSip project ..."
    build_lib
  fi
}

build_lib() {
 cd $PROJECT_DIR
 echo "cd $PROJECT_DIR"

 echo "Going to create  /pjlib/include/pj/config_site.h"
 
 file="$CURRENT_DIR/$ROOT_DIR/$PROJECT_DIR/pjlib/include/pj/config_site.h"
 echo "#define PJ_CONFIG_IPHONE 1" > $file
 echo "#define PJ_CONFIG_IPHONE 1" > $file
 echo "#include <pj/config_site_sample.h>" >> $file
 cat $file
 
 export ARCH="-arch $TARGET_ARCH"
 export MIN_IOS="-miphoneos-version-min=$MIN_IOS"
 
 if [ -d "$CURRENT_DIR/openssl/openssl-1_1_1$OPENSSL_VERSION/arm64" ]
  then
   echo "Configure-iphone with OpenSSL"
   ARCH="-arch $TARGET_ARCH" ./configure-iphone --with-ssl="$CURRENT_DIR/openssl/openssl-1_1_1$OPENSSL_VERSION/arm64"
  else
   echo "Configure-iphone without OpenSSL"
   ./configure-iphone
 fi
 
 make dep && make clean && make
 #/Users/asheeshgupta/Documents/pjsip_ssl_4_nov_22/openssl/openssl-1_1_1r/arm64
}

create_root_dir
download_zip
check_lib_unzip
check_lib_rename
check_build_lib


# cat <<EOF >"/pjlib/include/pj/config_site.h"
#  #define PJ_CONFIG_IPHONE 1
#  #include <pj/config_site_sample.h>
# EOF

#export DEVPATH=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer
## 64-bit simulator
#ARCH="-arch x86_64" CFLAGS="-O2 -m64 -mios-simulator-version-min=5.0" LDFLAGS="-O2 -m64 -mios-simulator-version-min=5.0" ./configure-iphone
## or 32-bit
## ARCH="-arch i386" CFLAGS="-O2 -m32 -mios-simulator-version-min=5.0" LDFLAGS="-O2 -m32 -mios-simulator-version-min=5.0" ./configure-iphone
#make dep && make clean && make
