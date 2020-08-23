#!/usr/bin/env bash
# This script is an central point to build the dependencies in third party
#

# exit immediately if a command fails
set -e

echo "********building dependencies for dev server ******"

#if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

# Get the parent directory of where this script is.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$( cd -P "$( dirname "$SOURCE" )/.." && pwd )"

# Change into that directory
cd "$DIR"

sudo apt-get update &&
sudo apt-get -y --no-install-recommends install apt-utils software-properties-common wget gpg-agent;
sudo apt-get -y clean

add-apt-repository -y ppa:ubuntu-toolchain-r/test;
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 apt-key add -;
echo 'deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-7 main' >> /etc/apt/sources.list;
echo 'deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-9 main' >> /etc/apt/sources.list;
apt-get update

apt-get -y --no-install-recommends install libtool
# compilers (gcc-7, gcc-9)
apt-get -y install build-essential g++-9 ninja-build
# CI dependencies
apt-get -y install git ssh tar gzip ca-certificates gnupg
# Python3
apt-get -y install python3-pip python3-setuptools
# other
apt-get -y install curl file gdb gdbserver ccache python3.6-dev openssl nodejs npm nginx
apt-get -y install gcovr cppcheck doxygen rsync graphviz graphviz-dev unzip vim zip pkg-config;
apt-get -y clean

if [ `uname -m` = "x86_64" ]; then
  apt-get -y --no-install-recommends install clang-7 lldb-7 lld-7 libc++-7-dev libc++abi-7-dev clang-format-7 clang-9;
  apt-get -y clean;
fi


# install cmake 3.14.0
curl -L -o /tmp/cmake.sh https://github.com/Kitware/CMake/releases/download/v3.14.0/cmake-3.14.0-Linux-x86_64.sh;
sh /tmp/cmake.sh --prefix=/usr/local --skip-license;
rm /tmp/cmake.sh


# install nodejs and npm
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install nodejs