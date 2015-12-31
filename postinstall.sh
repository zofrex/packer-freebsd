#!/bin/sh -e

# If HOST_HTTP_PROXY is not an empty string, set HTTP_PROXY to its value
if [ ! -z $HOST_HTTP_PROXY ]
then
  export HTTP_PROXY=$HOST_HTTP_PROXY
fi

freebsd-update fetch --not-running-from-cron
freebsd-update install

echo "WITH_PKGNG=	yes" >> /etc/make.conf

export ASSUME_ALWAYS_YES=yes

# Install sudo
pkg install sudo

# Add vagrant user
echo vagrant:::::::::vagrant | adduser -f -

# Set up SSH keys for vagrant user
mkdir -m go-rwx ~vagrant/.ssh
mv /tmp/vagrant.pub ~vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant ~vagrant/.ssh
chmod go-r ~vagrant/.ssh/authorized_keys

# Give vagrant sudoers access
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /usr/local/etc/sudoers
chmod u-w /usr/local/etc/sudoers
visudo -c
