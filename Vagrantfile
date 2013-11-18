# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|

  BOX_NAME = "precise64"
  BOX_URL = "http://files.vagrantup.com/precise64.box"

# config.vm.define :web do |web_config|
#   web_config.vm.box = BOX_NAME
#   web_config.vm.box_url = BOX_URL
#   web_config.vm.forward_port    80,  7887
# end

  config.vm.define :db do |db_config|

    db_config.vm.box = BOX_NAME
    db_config.vm.box_url = BOX_URL
    db_config.vm.forward_port  8080,  7887
    db_config.vm.forward_port 27017, 27017
    db_config.vm.provision :shell do |sh|
      sh.inline = <<-EOF
        export PUPPETMASTER="54.242.244.213"
        export FQDN="vm.lynr.co"
        export PUPPETENV="production"
        sh /vagrant/vm/vmsetup.sh
      EOF
    end

  end

end
