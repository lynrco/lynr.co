# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.5.0"

Vagrant.configure("2") do |config|

  BOX_NAME = "precise64"
  BOX_URL = "http://files.vagrantup.com/precise64.box"

# config.vm.define :web do |web_config|
#   web_config.vm.box = BOX_NAME
#   web_config.vm.box_url = BOX_URL
#   web_config.vm.forward_port    80,  7887
# end

  config.vm.define :db do |db_config|

      script = <<EOF
export PUPPETMASTER="54.242.244.213"
export FQDN="vm.lynr.co"
export PUPPETENV="production"
sh /vagrant/vm/vmsetup.sh
EOF
    db_config.vm.box = BOX_NAME
    db_config.vm.box_url = BOX_URL
    db_config.vm.network "forwarded_port", guest:  8080, host:  7887
    db_config.vm.network "forwarded_port", guest: 27017, host: 27017
    db_config.vm.provision :shell, inline: script
    db_config.vm.synced_folder ".", "/vagrant", type: "rsync"

  end

end
