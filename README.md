# lynr.co

Web project setup for lynr.co.

![Code Climate Status](https://d3s6mut3hikguw.cloudfront.net/repos/512bed31f3ea007f57067646/badges/fd545693f44365c7620f/gpa.png)

## EditorConfig

[Download EditorConfig](http://editorconfig.org/#download), install it and love
it. It will make me ❤ you.

## Development Cycle

Development can be done with a web server and other tasks running locally or
running on the vagrant machine. Please see [Local Development](#local-development)
for more information on running the web application locally.

### Setting up the Development Environment

The steps to do the baseline setup for local development are below. They
make some assumptions about your local setup. The primary assumption is
you are developing on a Mac with a recent version of OS X and that
[Homebrew](http://brew.sh) is installed. It also assumes you are running
or can run a build of Ruby 1.9.3. This can be accomplished with
[rbenv](https://github.com/sstephenson/rbenv) or [rvm](https://rvm.io).
[Node.js](http://nodejs.org) and [Grunt](http://gruntjs.com) are used to
build static files like CSS and JS. A [MongoDB](http://www.mongodb.org)
instance needs to be running for the Lynr web application to work (beyond
the landing page). Several actions will also require a running
[RabbitMQ][rabbitmq] and [Elasticsearch][es] instance. These can be
accomplished by installing it with Homebrew or by running it in a
virtual machine (see [Up and Running with Vagrant](#up-and-running-with-vagrant)).
Running these services inside a virtual machine with Vagrant is strongly
encouraged.

1. Editthe  `/etc/hosts` file (this may require super user priveleges) and
  append `127.0.0.1       lynr.co.local`
1. `brew install node rbenv ruby-build`
1. `rbenv install $(cat .ruby-version)`
1. `gem install bundler`
1. `rbenv rehash`
1. `bundle install`
1. `npm install`
1. `bundle exec rake lynr:bootstrap`

For the curious, more information about what `rake lynr:bootstrap` does
see [Configuration Files](#configuration-files) and [Self-Signed
Certificates](#self-signed-certificates).

### Local Development

Local machine development can be done without the need for a Vagrant virtual
machine by using a hosted MongoDB instance like [MongoHQ][mongohq]. The web
server and message queue processors run on the local development machine but
little else does. With this strategy in you will want to run a Ruby web server
via shotgun and run guard to compile LESS into CSS. If you are doing job
processing development you will also need to run the queue workers. The specific
commands are:

1. `bundle exec rake lynr:local` for the web server
  The `lynr:local` task uses the [shotgun gem][shotgunrb] to automatically
  reload Ruby files when they are changed.
1. `npm run-script grunt` for asset compilation. If the [grunt-cli][gruntcli]
  is already installed just run `grunt`. `grunt` will do an initial build and
  then watch for changes. Part of the grunt task is to generate source maps
  to show which .less file the styles came from.
1. `bundle exec guard -g rspec` for Ruby spec/test running
1. `bundle exec rake lynr:queues` for background jobs
1. `bundle exec rake lynr:events` for event processing

If you did the above and set up the external dependencies correctly
you should now have a server up and running. Point a browser to
[https://lynr.co.local:9393](http://lynr.co.local:9393) and see. The browse will
likely tell you about a certificate problem, this is because the certificate is
self-signed. Feel free to look at the certificate details to verify they are the
ones typed in when creating the certificate.

## Configuration Files

The application relies on the presence of two configuration files. Both of these
files use an environment variable, `whereami`, in the filename:

* `config/database.#{ENV['whereami']}.yaml`
* `config/app.#{ENV['whereami']}.yaml`
* `config/features.#{ENV['whereami']}.yaml`
* `config/events.#{ENV['whereami']}.yaml`

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

## Self-Signed Certificates

In order to develop with the [eBay](https://developer.ebay.com/) API you
will need a local SSL end point set up. In order to do this with the local
`shotgun` server some files must be created containing certificate
information. To generate the certificates execute the following steps
from the root of your working directory:

1. `openssl req -new > certs/server.cert.csr`. This will ask you a series
  of questions about the certificate. Sample output of this command is
  included below, see [Self-Signed Certificate Generation](#self-signed-certificate-generation)
1. `mv privkey.pem certs/`
1. `openssl rsa -in certs/privkey.pem -out certs/server.cert.key`
1. `openssl x509 -in certs/server.cert.csr -out certs/server.cert.crt -req -signkey certs/server.cert.key -days 365`

These steps will put the certificats in the certs directory with the names
that are used in the rake task, `bundle exec rake lynr:local` which runs
the local web server.

### Self-Signed Certificate Generation

These questions help to generate the certificate information. Information
in [] are defaults or suggested answers by the openssl software,
information after : are the provided answers. The PEM pass phrase is used
in another step of the certificate generation but then shouldn't be needed
again so this can be anything as long as it is more than four characters.
Common name must match whatever 'domain' you are using for local
development, 'lynr.co.local' is suggested but not required but it can not
be 'localhost' or '127.0.0.1'. Do not include provide an answer for 'A
challenge password' or 'An optional company name'.

    Generating a 1024 bit RSA private key
    .++++++
    ..............++++++
    writing new private key to 'privkey.pem'
    Enter PEM pass phrase:
    Verifying - Enter PEM pass phrase:
    -----
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [AU]:US
    State or Province Name (full name) [Some-State]:CA
    Locality Name (eg, city) []:Los Angeles
    Organization Name (eg, company) [Internet Widgits Pty Ltd]:Lynr, LLC
    Organizational Unit Name (eg, section) []:Tech
    Common Name (e.g. server FQDN or YOUR name) []:lynr.co.local
    Email Address []:email@domain.com

    Please enter the following 'extra' attributes
    to be sent with your certificate request
    A challenge password []:
    An optional company name []:

## Up and Running with Vagrant

Get up and running with these files locally using vagrant. A Vagrant box can
replace the need for hosted MongoDB, RabbitMQ and Elasticsearch servers
which may speed up development but because of the other external dependencies
(on things like Transloadit and Stripe) this is by no means necessary. These
steps are included largely for future planning.

1. Install [VirtualBox][vb]
1. Install [Vagrant][vagrant], must be newer than 1.5.0
1. Open Terminal or iTerm or whatever command line program tickles your fancy
1. Navigate to your working directory (wherever the source is cloned to)
1. Execute `vagrant up`

This gets a basic Ubuntu box up and running and exposes:

  * [MongoDB][mongodb] running on port 27017 (MongoDB default)
  * [RabbitMQ][rabbitmq] running on port 5672 (RabbitMQ default)
  * [Elasticsearch][es] running on port 9200 (Elasticsearch default)

---

Ignore the instructions after the rule, do the development locally for now.
Since Lynr is hosted on a PaaS provider the puppet configuration for a
web server is incomplete. The below instructions were an attempt to work
around that but the need for an SSL certificate means the [Unicorn][unicorn]
process needs to run behind an SSL endpoint (like Nginx or Apache) and
updating the Puppet manifests is not, at present, worth the effort.

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
[shotgunrb]: https://github.com/rtomayko/shotgun
[gruntcli]: https://www.npmjs.org/package/grunt-cli
[es]: http://www.elasticsearch.org
