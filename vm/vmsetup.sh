#!/bin/sh

# <UDF name="puppetmaster" label="Puppetmaster IP">
# PUPPETMASTER=
# <UDF name="fqdn" label="Fully Qualified Domain Name">
# FQDN=
# <UDF name="puppetenv" label="Puppet Environment">
# PUPPETENV=

IPADDR=`ip -f inet -r addr | egrep -o "(([0-9]{1,3}+).*)/24" | sed 's/\/24//'`
LOCALENV=${PUPPETENV:-production}

# By installing puppet this directory is created, so don't re-run the setup
if [ ! -d /etc/puppet ]; then
  # Set ip for puppetmaster in /etc/hosts
  echo "" >> /etc/hosts
  echo "$PUPPETMASTER puppet.bryanwrit.es puppet puppetmaster" >> /etc/hosts
  echo "$IPADDR $FQDN" >> /etc/hosts
  # Set hostname
  echo "$FQDN" > /etc/hostname
  hostname -F /etc/hostname

  # Download and install puppet
  wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
  dpkg -i puppetlabs-release-precise.deb
  apt-get update
  apt-get install -y puppet
fi

# By downloading the ssl certs we created this directory
if [ ! -d /var/lib/puppet/ssl ]; then
  tar xfz /vagrant/vm/cert/${FQDN}.pem.tgz -C /var/lib/puppet/
  cp /vagrant/vm/puppet.conf /etc/puppet/puppet.conf
fi

puppet agent --server=puppet.bryanwrit.es --environment=$PUPPETENV --no-daemonize --onetime
