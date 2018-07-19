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

# Don't spawn dialogs when installing ports
BATCH=yes

# Fetch the port tree
echo "Updating ports tree"
portsnap --interactive fetch extract > /tmp/build-logs/portsnap.log 2>&1

echo "Installing sudo"

echo "security_sudo_SET += NOARGS_SHELL INSULTS" >> /etc/make.conf
cd /usr/ports/security/sudo
echo "[$(/bin/date)] Installing $(pwd):" >> /var/log/ports
make install > /var/log/ports 2>&1

echo "Installing rsync"

cd /usr/ports/net/rsync
echo "[$(/bin/date)] Installing $(pwd):" >> /var/log/ports
make install > /var/log/ports 2>&1

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
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /usr/local/etc/sudoers
chmod u-w /usr/local/etc/sudoers

echo "Sanity checking sudoers file"
visudo -c
