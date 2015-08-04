#!/usr/bin/env sh
set -e

if [ ! -d tmp ]; then
  echo Creating tmp directory
  mkdir tmp
fi

if [ ! -f tmp/vagrant.pub ]; then
  echo Downloading Vagrant public key
  cd tmp
  curl -O https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
fi
