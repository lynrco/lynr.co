# quicklist.it API

API project setup for quicklist.it service.

## Vagrant

Get up and running with these files locally using vagrant

1. Install [VirtualBox][vb]
1. Install [Vagrant][vagrant]
1. Open Terminal or iTerm or whatever command line program tickles your fancy
1. Navigate to your working directory
1. Edit `/etc/hosts` file and append `127.0.0.1       api.quicklist.it.local`
1. Execute `vagrant api up`

This gets a basic Ubuntu box up and running but there are extra steps to get
the box ready to server the application.

1. `sudo apt-get install build-essential ruby ruby-dev rubygems`
1. `sudo gem install bundler -v 1.2.3`
1. 

1. Execute `vagrant ssh` to ssh into the virtual machine
1. Execute `mkdir pids logs` to create the location for unicorn to store files
1. Execute `cd /vagrant/api` to get to the working directory on the VM
1. Execute `bundle install` to get the Ruby dependencies
1. Execute `bundle exec unicorn -D -c config/unicorn.vagrant.conf.rb` to start the Ruby web server
    * If you get an error about unicorn not being installed execute `sudo gem install unicorn`
1. Execute `bundle exec guard -p` to watch files and restart the [unicorn][unicorn]
   web server when files change

Now the server is up and running open a browser to
[http://api.quicklist.it.local:7887](http://newproject.ipglab.local:7878)

## EditorConfig

[Download EditorConfig](http://editorconfig.org/#download), for the love of all that is holy.

[vagrant]: http://downloads.vagrantup.com
[vb]: https://www.virtualbox.org/wiki/Downloads
[puppet]: http://www.puppetlabs.com
[unicorn]: http://unicorn.bogomips.org

