# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|

  BOX_NAME = "precise64"
  BOX_URL = "http://files.vagrantup.com/precise64.box"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  # config.vm.network :hostonly, "192.168.33.10"

  # config.vm.forward_port 80, 8080

  # config.vm.share_folder "v-data", "/vagrant_data", "../data"

  config.vm.define :api do |api_config|

    api_config.vm.box = BOX_NAME
    api_config.vm.box_url = BOX_URL
    api_config.vm.network :hostonly, "10.11.12.120"
    api_config.vm.forward_port 80, 7887
    api_config.vm.provision :shell do |sh|
      sh.inline = <<-EOF
        # dotdeb.org
        echo "deb http://packages.dotdeb.org squeeze all" | sudo tee /etc/apt/sources.list.d/dotdeb.list > /dev/null
        echo "deb-src http://packages.dotdeb.org squeeze all" | sudo tee -a /etc/apt/sources.list.d/dotdeb.list > /dev/null
        wget http://www.dotdeb.org/dotdeb.gpg
        cat dotdeb.gpg | sudo apt-key add -
        rm dotdeb.gpg
        # mongodb
        sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
        echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen" | sudo tee /etc/apt/sources.list.d/10gen.list > /dev/null
        # Basic update/upgrade
        sudo apt-get update
        sudo apt-get upgrade -y
        # Install Ruby
        sudo apt-get install -y build-essential ruby1.9.1
        gem install bundler -v 1.2.4
        # Install nginx and mongodb
        sudo apt-get install -y nginx mongodb-10gen
      EOF
    end

  end

end
