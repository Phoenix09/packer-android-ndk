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
	echo >> .profile
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
	16)
		ndk android-ndk-r16b-linux-x86_64.zip
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


# Android SDK
# Set environment variables
echo >> .profile
export ANDROID_SDK="$HOME/android-sdk"
echo "export ANDROID_SDK=$ANDROID_SDK" >> .profile
export PATH="$PATH:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools"
echo 'export PATH=$PATH:$ANDROID_SDK/tools/bin:$ANDROID_SDK/platform-tools:$ANDROID_NDK/build-tools/26.0.0' >> .profile

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

# Install build-tools, platforms, and Android extras
# We can't install everything here because licensing for some components doesn't permit redistribution
PACKAGES="$(sdkmanager --list --verbose 2> /dev/null | grep -P '^(build-tools|platforms)' | tr '\n' ' ')"
sdkmanager $PACKAGES 'extras;android;m2repository'

# Add a script to update everything
# We won't enable this by default, if you want to you can add it as a provisioner:
#	Vagrant.configure("2") do |config|
#	  config.vm.provision "shell",
#	    inline: "$HOME/sdk-update.sh"
#	end
cat << 'EOF' >> $HOME/sdk-update.sh
#!/bin/sh
sdkmanager --update
PACKAGES="$(sdkmanager --list --verbose 2> /dev/null | grep -P '^(build-tools|platforms|extras)' | tr '\n' ' ')"
sdkmanager $PACKAGES
EOF

chmod +x $HOME/sdk-update.sh

