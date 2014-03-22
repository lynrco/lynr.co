# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.5.0"

Vagrant.configure("2") do |c|

  BOX_NAME = "precise64"
  BOX_URL = "http://files.vagrantup.com/precise64.box"

  script = <<EOF
export PUPPETMASTER="54.242.244.213"
export FQDN="vm.lynr.co"
export PUPPETENV="production"
sh /vagrant/vm/vmsetup.sh
EOF

  c.vm.define :db do |config|

    config.vm.provider :virtualbox do |vbox, override|
      vbox.customize ["modifyvm", :id, "--memory", 512]
    end

    config.vm.provider :vmware_fusion do |vbox, override|
      vbox.customize ["modifyvm", :id, "--memory", 512]
    end
    config.vm.box = BOX_NAME
    config.vm.box_url = BOX_URL
    config.vm.network "forwarded_port", guest:  8080, host:  7887
    config.vm.network "forwarded_port", guest:  9200, host:  9200
    config.vm.network "forwarded_port", guest: 27017, host: 27017
    config.vm.provision :shell, inline: script
    config.vm.synced_folder ".", "/vagrant", type: "rsync"

  end

end
