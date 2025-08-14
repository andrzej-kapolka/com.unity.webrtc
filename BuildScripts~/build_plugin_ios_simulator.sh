#!/bin/bash -eu

export LIBWEBRTC_DOWNLOAD_URL=https://github.com/Unity-Technologies/com.unity.webrtc/releases/download/M116/webrtc-ios.zip
export ARTIFACTS_DIR="$(pwd)/artifacts"
export SOLUTION_DIR=$(pwd)/Plugin~
export WEBRTC_FRAMEWORK_DIR=$(pwd)/Runtime/Plugins/iOS-simulator
export WEBRTC_ARCHIVE_DIR=build/webrtc.xcarchive
export WEBRTC_SIM_ARCHIVE_DIR=build/webrtc-sim.xcarchive

# Install cmake
export HOMEBREW_NO_AUTO_UPDATE=1
brew install cmake

# Unzip webrtc 
#curl -L $LIBWEBRTC_DOWNLOAD_URL > webrtc.zip
unzip -o -d $SOLUTION_DIR/webrtc "$ARTIFACTS_DIR/webrtc-ios-simulator.zip"

# Build webrtc Unity plugin 
cd "$SOLUTION_DIR"
cmake . \
  --fresh \
  -G Xcode \
  -D CMAKE_SYSTEM_NAME=iOS \
  -D "CMAKE_OSX_ARCHITECTURES=arm64;x86_64" \
  -D CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH=NO \
  -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -D CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET=12.0 \
  -B build

xcodebuild \
  -sdk iphonesimulator \
  -project build/webrtc.xcodeproj \
  -target WebRTCLib \
  -configuration Release

xcodebuild archive \
  -sdk iphonesimulator \
  -scheme WebRTCPlugin \
  -project build/webrtc.xcodeproj \
  -configuration Release \
  -archivePath "$WEBRTC_SIM_ARCHIVE_DIR"

rm -rf "$WEBRTC_FRAMEWORK_DIR/webrtc.framework"
mkdir "$WEBRTC_FRAMEWORK_DIR"
cp -r "$WEBRTC_SIM_ARCHIVE_DIR/Products/@rpath/webrtc.framework" "$WEBRTC_FRAMEWORK_DIR/webrtc.framework"

# todo(kazuki): The command below combines two libraries for supporting iOS and iOS simulator.
# But currently this is commented out because the combined binary adds a troublesome task to developer 
# when building iOS app on XCode. We need to support it using XCFramework or another way.
# 
#lipo -create -o "$WEBRTC_FRAMEWORK_DIR/webrtc.framework/webrtc" \
#   "$WEBRTC_ARCHIVE_DIR/Products/@rpath/webrtc.framework/webrtc" \
#   "$WEBRTC_SIM_ARCHIVE_DIR/Products/@rpath/webrtc.framework/webrtc"