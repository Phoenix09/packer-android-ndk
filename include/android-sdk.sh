#!/bin/sh
if [ "$(id -ru)" = 0 ]; then
	exec sudo -H -E -u vagrant "$0"
fi
set -e

trap 'rm -rf "$TMP"' EXIT INT TERM
TMP="$(mktemp -d)"

cd "$HOME"

# Set environment variables
export ANDROID_SDK="$HOME/android-sdk"
echo "export ANDROID_SDK=$ANDROID_SDK" >> .profile
export PATH="$PATH:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools"
echo 'export PATH=$PATH:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools' >> .profile

# Android SDK
wget -nv https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip -P "$TMP"
mkdir -p "$ANDROID_SDK"
unzip -o -d "$ANDROID_SDK" "$TMP/sdk-tools-linux-3859397.zip"

# Silence useless warning
mkdir -p "$HOME/.android"
touch "$HOME/.android/repositories.cfg"

# Accept licenses
yes | sdkmanager --licenses

# Update Android SDK
sdkmanager --update

# Install all the things
sdkmanager 'build-tools;19.1.0' 'build-tools;20.0.0' 'build-tools;21.1.2' \
	'build-tools;22.0.1' 'build-tools;23.0.3' 'build-tools;24.0.3' \
	'build-tools;25.0.3' 'build-tools;26.0.0' 'platform-tools' \
	'platforms;android-21' 'platforms;android-22' 'platforms;android-23' \
	'platforms;android-24' 'platforms;android-25' 'build-tools;19.1.0' \
	'build-tools;20.0.0' 'build-tools;21.1.2' 'build-tools;22.0.1' \
	'build-tools;23.0.1' 'build-tools;23.0.2' 'build-tools;23.0.3' \
	'build-tools;24.0.0' 'build-tools;24.0.1' 'build-tools;24.0.2' \
	'build-tools;24.0.3' 'build-tools;25.0.0' 'build-tools;25.0.1' \
	'build-tools;25.0.2' 'build-tools;25.0.3' 'build-tools;26.0.0' \
	'build-tools;26.0.1' 'platform-tools' 'platforms;android-10' \
	'platforms;android-11' 'platforms;android-12' 'platforms;android-13' \
	'platforms;android-14' 'platforms;android-15' 'platforms;android-16' \
	'platforms;android-17' 'platforms;android-18' 'platforms;android-19' \
	'platforms;android-20' 'platforms;android-21' 'platforms;android-22' \
	'platforms;android-23' 'platforms;android-24' 'platforms;android-25' \
	'platforms;android-26' 'platforms;android-7' 'platforms;android-8' \
	'platforms;android-9'
