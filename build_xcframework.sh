#!/bin/bash

set -e

# Define build configurations and platforms
CONFIGURATIONS=("Release")
PLATFORMS=("iphoneos" "iphonesimulator")

# Clean previous build artifacts
rm -rf build

# Build the libraries for each configuration and platform
for config in "${CONFIGURATIONS[@]}"; do
  for platform in "${PLATFORMS[@]}"; do
    # Add -DBUILD_ANDROID=OFF for iOS build
    cmake -S . -B "build/$config-$platform" -G Xcode -DBUILD_ANDROID=OFF

    xcodebuild -project "build/$config-$platform/qrllib.xcodeproj" \
               -scheme ALL_BUILD \
               -configuration "$config" \
               -sdk "$platform" \
               -derivedDataPath "build/$config-$platform/DerivedData" \
               -UseNewBuildSystem=YES \
               CODE_SIGN_IDENTITY="Apple Development" \
               DEVELOPMENT_TEAM="PHJGP7VK4N" \
               IPHONEOS_DEPLOYMENT_TARGET=12.0 \
               build
  done
done

# Create xcframeworks
for library in shasha qrllib kyber wallet; do
  xcodebuild -create-xcframework \
             -framework "build/Release-iphoneos/Release/$library.framework" \
             -framework "build/Release-iphonesimulator/Release/$library.framework" \
             -output "build/$library.xcframework" \

done

for library in shasha qrllib kyber wallet; do
  for plist in build/$library.xcframework/ios-arm64/$library.framework/Info.plist \
               build/$library.xcframework/ios-arm64_x86_64-simulator/$library.framework/Info.plist; do
    if [ -f "$plist" ]; then
      echo "Patching $plist"
      /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string 1.0.0" "$plist" 2>/dev/null || \
      /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.0.0" "$plist"
      /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string 1" "$plist" 2>/dev/null || \
      /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1" "$plist"
      /usr/libexec/PlistBuddy -c "Add :MinimumOSVersion string 12.0" "$plist" 2>/dev/null || \
      /usr/libexec/PlistBuddy -c "Set :MinimumOSVersion 12.0" "$plist"
    fi
  done
done

# Copy xcframeworks to the ios folder
mkdir -p ios/Frameworks
for library in shasha qrllib kyber wallet; do
  cp -R "build/$library.xcframework" "ios/Frameworks/"
done

