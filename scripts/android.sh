#!/bin/sh
if [ "$(id -ru)" = 0 ]; then
	exec sudo -H -E -u vagrant "$0"
fi
set -e

trap 'rm -rf "$TMP"' EXIT INT TERM
TMP="$(mktemp -d)"

sudo hostname ubuntu-android-zesty-amd64
sudo sh -c 'printf ubuntu-android-zesty-amd64 > /etc/hostname'

sudo apt-get update
sudo apt-get install -y unzip openjdk-8-jdk-headless git python autoconf automake ant autopoint cmake build-essential libtool patch pkg-config ragel subversion wget

wget -nv -O "$TMP/protoc-3.3.0-linux-x86_64.zip" https://github.com/google/protobuf/releases/download/v3.3.0/protoc-3.3.0-linux-x86_64.zip
sudo unzip -o -j "$TMP/protoc-3.3.0-linux-x86_64.zip" bin/protoc -d /usr/local/bin/

cd "$HOME"

# Android NDK
ndk() {
	wget -nv "https://dl.google.com/android/repository/$1" -P "$TMP"
	unzip -o "$TMP/$1"
	export ANDROID_NDK="$HOME/${1%-linux-*.zip}"
	echo "export ANDROID_NDK=$ANDROID_NDK" >> .profile
}

case "$NDK_VERSION" in
	9)
		wget -nv https://dl.google.com/android/ndk/android-ndk-r9d-linux-x86_64.tar.bz2 -P "$TMP"
		tar xvf "$TMP/android-ndk-r9d-linux-x86_64.tar.bz2"
		export ANDROID_NDK="$HOME/android-ndk-r9d"
		echo "export ANDROID_NDK=$ANDROID_NDK" >> .profile
		;;
	10)
		ndk android-ndk-r10e-linux-x86_64.zip
		;;
	11)
		ndk android-ndk-r11c-linux-x86_64.zip
		;;
	12)
		ndk android-ndk-r12b-linux-x86_64.zip
		;;
	13)
		ndk android-ndk-r13b-linux-x86_64.zip
		;;
	14)
		ndk android-ndk-r14b-linux-x86_64.zip
		;;
	15)
		ndk android-ndk-r15c-linux-x86_64.zip
		;;
	"")
		echo "FATAL: no NDK_VERSION specified"
		exit 1
		;;
	*)
		echo "FATAL: invalid NDK_VERSION specified: $NDK_VERSION"
		exit 1
		;;
esac
