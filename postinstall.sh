#!/bin/sh -eu

# If HOST_HTTP_PROXY is not an empty string, set HTTP_PROXY to its value
if [ ! -z "$HOST_HTTP_PROXY" ]
then
  export HTTP_PROXY="$HOST_HTTP_PROXY"
  echo "Using HTTP proxy: $HTTP_PROXY"
fi

mkdir /tmp/build-logs

echo "Adding disks"

set parity1 data1 data2 parity2 data3

for i in $(seq 1 $#)
do
  gpart create -s GPT da$i
  gpart add -t freebsd-ufs da$i
  newfs -U /dev/da${i}p1 > /dev/null
  mkdir -p /stor/$1
  echo "/dev/da${i}p1	/stor/$1	ufs	rw	0	2" >> /etc/fstab
  shift
done

echo "Checking for updates"
freebsd-update fetch --not-running-from-cron > /tmp/build-logs/freebsd-update.log
echo "Installing updates"
freebsd-update install 2>&1 | tee -a /tmp/build-logs/freebsd-update.log

# allow pkg to function without a TTY
export ASSUME_ALWAYS_YES=yes

echo "Installing sudo"
pkg install sudo

echo "Installing rsync"
pkg install rsync

# Add vagrant user
echo "Adding vagrant user"

# name:uid:gid:class:change:expire:gecos:home_dir:shell:password
echo vagrant::::::::csh:vagrant | adduser -f -

# Set up SSH keys for vagrant user
mkdir -m go-rwx ~vagrant/.ssh
mv /tmp/vagrant.pub ~vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant ~vagrant/.ssh
chmod go-r ~vagrant/.ssh/authorized_keys

# Give vagrant sudoers access
echo "Adding vagrant to sudoers"
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /usr/local/etc/sudoers
chmod u-w /usr/local/etc/sudoers

echo "Sanity checking sudoers file"
visudo -c
