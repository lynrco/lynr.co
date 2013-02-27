# lynr.co API

API project setup for lynr.co service.

## Up and Running with Vagrant

Get up and running with these files locally using vagrant

1. Install [VirtualBox][vb]
1. Install [Vagrant][vagrant]
1. Open Terminal or iTerm or whatever command line program tickles your fancy
1. Navigate to your working directory (wherever the source is cloned to)
1. Edit `/etc/hosts` file and append `127.0.0.1       lynr.co.local`
  * This may require super user priveleges
1. Execute `vagrant up api`

This gets a basic Ubuntu box up and running but there are extra steps to get
the box ready to server the application.

### Box Dependencies

The Ubuntu box needs to have some things installed on it for the application to
run properly. After bringing up the box for the first time do the following inside
the vagrant box. Get into the vagrant box by running `vagrant ssh api`.

1. Execute `sudo apt-get install build-essential ruby1.9.3`
1. Execute `sudo gem install bundler -v 1.2.3`
1. Execute `bundle install` from the `/vagrant` directory to get the Ruby dependencies

### Development Cycle

When ready to start development the basic steps should be similar to the following
starting from the local machine.

1. Execute `vagrant ssh api` to ssh into the virtual machine
1. Execute `mkdir pids logs` (from `/home/vagrant`) to create the location for
   unicorn to store files
1. Execute `cd /vagrant` to get to the working directory on the VM
1. Execute `bundle exec unicorn -D -c config/unicorn.vagrant.conf.rb` to start
   the Ruby web server in the background
1. Execute `bundle exec guard -p` to watch files and restart the [unicorn][unicorn]
   web server when files change

Now the server is up and running open a browser to
[http://lynr.co.local:7887](http://lynr.co.local:7887)

## EditorConfig

[Download EditorConfig](http://editorconfig.org/#download), for the love of all that is holy.

[vagrant]: http://downloads.vagrantup.com
[vb]: https://www.virtualbox.org/wiki/Downloads
[puppet]: http://www.puppetlabs.com
[unicorn]: http://unicorn.bogomips.org

