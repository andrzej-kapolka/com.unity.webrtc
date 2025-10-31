#!/bin/bash -eu

export LIBWEBRTC_DOWNLOAD_URL=https://github.com/Unity-Technologies/com.unity.webrtc/releases/download/M116/webrtc-mac.zip
export ARTIFACTS_DIR="$(pwd)/artifacts"
export SOLUTION_DIR=$(pwd)/Plugin~
export DYLIB_FILE=$(pwd)/Runtime/Plugins/macOS/libwebrtc.dylib

# Install cmake
export HOMEBREW_NO_AUTO_UPDATE=1
brew install cmake

# Download LibWebRTC
#curl -L $LIBWEBRTC_DOWNLOAD_URL > webrtc.zip
unzip -o -d $SOLUTION_DIR/webrtc "$ARTIFACTS_DIR/webrtc-mac.zip"

# Remove old dylib file
rm -rf "$DYLIB_FILE"

# Build UnityRenderStreaming Plugin
cd "$SOLUTION_DIR"
cmake --preset=macos -D CMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build --preset=release-macos --target=WebRTCPlugin
