#!/bin/bash
#https://github.com/openssl/openssl

OPENSSL_LIB_VERSION=1_1_1q
FORCE_BUILD="false"

if [ -n "$1" ]
then
OPENSSL_LIB_VERSION=1_1_1$1
fi

if [ -n "$2" ]
then
FORCE_BUILD=$2
fi

sudo chmod +x openssl.sh
echo "CURRENT_DIR=$PWD"

#Variables
CURRENT_DIR=$PWD
ROOT_DIR=openssl

OPENSSL_ZIP_NAME=OpenSSL_$OPENSSL_LIB_VERSION
OPENSSL_UN_ZIP_NAME=openssl-$OPENSSL_ZIP_NAME

OPENSSL_DIR_NAME=openssl-$OPENSSL_LIB_VERSION

create_root_dir()
{
if [ -d "$PWD/$ROOT_DIR" ]
 then
    echo "Directory '$ROOT_DIR' already exists."
 else
    echo "Created '$ROOT_DIR' directory."
    mkdir $ROOT_DIR
fi
}

download_open_ssl_zip() {
 cd $ROOT_DIR

 if [ -f "$PWD/$OPENSSL_ZIP_NAME.zip" ];
  then
    echo "$OPENSSL_ZIP_NAME.zip is already exist"
 else
    echo "$OPENSSL_ZIP_NAME.zip does not exist, downloading zip file...."
    sudo wget https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_$OPENSSL_LIB_VERSION.zip
  fi
}

unzip_openssl_lib() {
 if [ -d "$CURRENT_DIR/$ROOT_DIR/$OPENSSL_DIR_NAME" ]
  then
    rm -r dirname $CURRENT_DIR/$ROOT_DIR/$OPENSSL_DIR_NAME
 fi
 
  if [ -d "$CURRENT_DIR/$ROOT_DIR/$OPENSSL_UN_ZIP_NAME" ]
  then
     rm -r dirname $CURRENT_DIR/$ROOT_DIR/$OPENSSL_UN_ZIP_NAME
  fi
 
 if [ -r "$CURRENT_DIR/$ROOT_DIR/$OPENSSL_ZIP_NAME.zip" ]
  then
    echo "##### ****** Unziping Started...####'$OPENSSL_ZIP_NAME'.zip file.....****** #########"
    unzip $OPENSSL_ZIP_NAME.zip
    echo "#####  ****** Unziping Completed. ****** #############"
 fi
}

rename_openssl_lib_dir() {
 if [ -d "$CURRENT_DIR/$ROOT_DIR/$OPENSSL_UN_ZIP_NAME" ]
  then
   echo "Renaming $OPENSSL_UN_ZIP_NAME into $OPENSSL_DIR_NAME"
   mv $OPENSSL_UN_ZIP_NAME $OPENSSL_DIR_NAME
  else
   echo "Directory '$OPENSSL_UN_ZIP_NAME' does not exists."
  fi
}

build_openssl_lib() {
 cd $OPENSSL_DIR_NAME
 echo "cd $OPENSSL_DIR_NAME"
 
 IPHONEOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)
 
 echo "Export CC"
 export CC=clang;
 echo "Export CROSS_TOP"
 export CROSS_TOP=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
 
 echo "Export CROSS_SDK= $IPHONEOS_SDK"
 export CROSS_SDK=iPhoneOS16.0.sdk
 export PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin:$PATH"
 
 rm -r dirname $CURRENT_DIR/$ROOT_DIR/$OPENSSL_DIR_NAME/arm64
 mkdir $CURRENT_DIR/$ROOT_DIR/$OPENSSL_DIR_NAME/arm64
   
 ./Configure ios64-cross no-shared no-dso no-hw no-engine --prefix=$CURRENT_DIR/$ROOT_DIR/$OPENSSL_DIR_NAME
 
 echo "Executing 'make'"
 make
 echo "Executing 'make install'"
 make install
}

execute_openssl_lib() {
 cd $OPENSSL_DIR_NAME
 echo "cd $OPENSSL_DIR_NAME"

 IPHONEOS_SDK=$(xcrun --sdk iphoneos --show-sdk-path)

 echo "Export CROSS_TOP"
 export CROSS_TOP=/Applications/XCode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer
 echo "Export CROSS_SDK= $IPHONEOS_SDK"
 export CROSS_SDK=iPhoneOS16.0.sdk
 echo "Export CC"
 export CC="/Applications/XCode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -arch arm64"
 echo "Configure iphoneos-cross"
 
 rm -r dirname $CURRENT_DIR/$ROOT_DIR/$OPENSSL_DIR_NAME/arm64
 mkdir $CURRENT_DIR/$ROOT_DIR/$OPENSSL_DIR_NAME/arm64
 
 ./Configure iphoneos-cross --prefix=$CURRENT_DIR/$ROOT_DIR/$OPENSSL_DIR_NAME/arm64
 echo "Executing 'make'"
 make
 echo "Executing 'make install'"
 make install
}

check_force_build() {
   if [ $FORCE_BUILD == "true" ]
    then
     echo "OpenSSL found but forced building...."
     build_lib
    else
     echo "OpenSSL Already Exists.....Not rebuilding..."
   fi
}

build_lib() {
   execute_openssl_lib
   #build_openssl_lib
}

build() {
if [ -d "$CURRENT_DIR/$ROOT_DIR/$OPENSSL_DIR_NAME/arm64" ]
 then
   echo "OpenSSL Already Exists....."
   check_force_build
 else
   echo "OpenSSL does not exist.....Building it..."
   build_lib
fi
}

force_unzip_check() {
    if [ $FORCE_BUILD == "true" ]
    then
     echo "OpenSSL ZIP found but forced unzipping...."
     unzip_openssl_lib
    else
     echo "Openssl Unzip not required. OpenSSL Already Exists....."
   fi
}

unzip_root_lib() {
if [ -d "$CURRENT_DIR/$ROOT_DIR/$OPENSSL_DIR_NAME/arm64" ]
 then
   echo "Openssl Already Exists..... Checcking force unzip if required....."
   force_unzip_check
 else
   echo "Unzipping openSSL....."
   unzip_openssl_lib
fi
}

create_root_dir
download_open_ssl_zip
unzip_root_lib
rename_openssl_lib_dir
build
