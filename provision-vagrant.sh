#!/bin/bash

set -ex

# Copy the git submodule checkout over into home
cp -r /vagrant/trove-integration ~

cd ~/trove-integration/scripts
# Disable Swift
sed -e 's/ENABLED_SERVICES+=,s-proxy/#ENABLED_SERVICES+=,s-proxy/' -i localrc.rc
# Enable screen logging to files, and use Qemu instead of KVM for libvirt
tee -a localrc.rc <<EOF
SCREEN_LOGDIR="/opt/stack/logs"
LIBVIRT_TYPE="qemu"
EOF

# Install Redstack (this also clones, installs and enables DevStack)
./redstack install

# Set up Trove for MySQL
# (includes building the Trove-enabled MySQL image with diskimage-builder)
./redstack kick-start mysql no-clean

# Make sure we source ~/devstack/openrc on login
echo ". ~/devstack/openrc " >> ~/.bashrc

# Finally, copy the shell scripts into $HOME (from /vagrant), so
# they are still present even after the VM is turned into an
# appliance and is no longer managed by Vagrant.
cp /vagrant/*.sh ~
