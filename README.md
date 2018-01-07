## Features
* Android NDK
* Android SDK with build-tools and APIs installed
    * Other components are not preinstalled due to licensing restrictions.
     You can install them manually using `sdkmanager`.
    * The included `sdk-update.sh` script will update existing packages and install new platforms and build-tools:
        ```ruby
        Vagrant.configure("2") do |config|
          config.vm.provision "shell",
            privileged: false,
            inline: '$HOME/sdk-update.sh'
        end
        ```
* Preinstalled packages:
    * unzip openjdk-8-jdk-headless git python autoconf automake ant autopoint cmake build-essential libtool patch pkg-config ragel subversion wget
    * protoc v3.3.0

## Usage
```shell
vagrant init Phoenix09/android-ndk-VERSION
```
Where VERSION is a supported NDK version:
Version | NDK Revision
--------|--------
9 | 9d
10 | 10e
11 | 11c
12 | 12d
13 | 13b
14 | 14b
15 | 15c
16 | 16b

## Building
* `make all` in the root directory will build all boxes.
* `make help` will show available targets.
