# lynr.co

Web project setup for lynr.co.

*Status:*
![Travis CI Build Status](https://api.travis-ci.com/bryanjswift/lynr.co.png?token=oxLp1vGhsNdKTFeLPEqN)
![Code Climate Status](https://d3s6mut3hikguw.cloudfront.net/repos/512bed31f3ea007f57067646/badges/fd545693f44365c7620f/gpa.png)

## EditorConfig

[Download EditorConfig](http://editorconfig.org/#download), install it and love
it. It will make me ❤ you.

## Configuration Files

The application relies on the presence of two configuration files. Both of these
files use an environment variable, `whereami`, in the filename:

* `config/database.#{ENV['whereami']}.yaml`
* `config/app.#{ENV['whereami']}.yaml`

There are example files committed to source control containing the fields necessary
for operation. Many of the configuration values are API keys for third party services.
The default environment is 'development' so copy `config/database.example.yaml` to 
`config/database.development.yaml` and `config/app.example.yaml` to
`config/app.development.yaml` and fill in the appropriate values.
In order to have a completely functional application you will need an account on
the following services:

* [Mailgun](http://www.mailgun.com)
* [Stripe](http://www.stripe.com)
* [Transloadit](http://www.transloadit.com)
* [RabbitMQ][rabbitmq] SaaS provider, [CloudAMQP](http://www.cloudamqp.com) is a
  decent, free, choice.

## Development Cycle

Development can be done with a web server and other tasks running locally or
running on the vagrant machine. In both cases `bundle install` must be executed
on the local machine in order to install the Ruby dependencies. Because of the
way the Lynr application is architected right now it will likely be faster to
get up and running using your local machine for development and relying on
SaaS providers for dependencies.

### Local Development

Local machine development can be done without the need for a Vagrant virtual
machine by using a hosted MongoDB instance like [MongoHQ][mongohq]. The web
server and message queue processors run on the local development machine but
little else does. With this strategy in you will want to run a Ruby web server
via shotgun and run guard to compile LESS into CSS. If you are doing job
processing development you will also need to run the queue workers. The specific
commands are:

1. `bundle exec shotgun` for the web server
1. `bundle exec guard -g local` for asset compilation
1. `bundle exec rake worker:all` for queue workers

If you did the above and set up the external dependencies correctly
you should now have a server up and running. Point a browser to
[http://lynr.co.local:9393](http://lynr.co.local:9393) and see.

## Up and Running with Vagrant

Get up and running with these files locally using vagrant. A Vagrant box can
replace the need for a hosted MongoDB server and a hosted RabbitMQ server
which may speed up development but because of the other external dependencies
(on things like Transloadit and Stripe) this is by no means necessary. These
steps are included largely for future planning.

1. Install [VirtualBox][vb]
1. Install [Vagrant][vagrant]
1. Open Terminal or iTerm or whatever command line program tickles your fancy
1. Navigate to your working directory (wherever the source is cloned to)
1. Edit `/etc/hosts` file and append `127.0.0.1       lynr.co.local`
  * This may require super user priveleges
1. Execute `vagrant up`

This gets a basic Ubuntu box up and running and exposes [MongoDB][mongodb] running
on port 27017 (the default).

### Box Dependencies

The Ubuntu box needs to have some things installed on it for the web serving
application to run properly. After bringing up the box for the first time
(which will take a while) do the following on the command line from the working
directory on your local machine. These steps are 'one-time' setup steps, the
last `bundle install` step may need to be repeated if dependencies are added
or updated.

1. Execute `vagrant ssh` to ssh into the virtual machine
1. Execute `mkdir pids logs` (from `/home/vagrant`) to create the location for
   unicorn to store files
1. Execute `cd /vagrant` to get to the working directory on the VM
1. Execute `bundle install` to get the Ruby dependencies

### Vagrant Development

When ready to start development the basic steps should be similar to the following
starting from the local machine.

1. Execute `vagrant ssh` to ssh into the virtual machine
1. Execute `cd /vagrant` to get to the working directory on the VM
1. Execute `bundle exec unicorn -D -c config/unicorn.vagrant.conf.rb` to start
   the Ruby web server in the background
1. Execute `bundle exec guard -p -l 5 -g vagrant` to watch files and restart
   the [unicorn][unicorn] web server when files change.

Now the server is up and running open a browser to
[http://lynr.co.local:7887](http://lynr.co.local:7887).

*Note:* Because of the way Vagrant interacts with the filesystem the '-p'
argument to guard must be used. '-p' tells guard to poll the filesystem for
changes, the '-l 5' argument above defines how often the filesystem is polled
for changes in seconds. The default value for for time between polls appears
to be one (1) second, this can cause extremely high CPU usage for the Vagrant
virtual machine; five (5) seconds seems to strike a nice balance between
responsiveness and CPU usage.


[vagrant]: http://downloads.vagrantup.com
[vb]: https://www.virtualbox.org/wiki/Downloads
[puppet]: http://www.puppetlabs.com
[unicorn]: http://unicorn.bogomips.org
[mongodb]: http://www.mongodb.org
[rabbitmq]: http://www.rabbitmq.com
[mongohq]: https://www.mongohq.com
