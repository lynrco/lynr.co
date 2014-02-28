require 'log4r'
require './lib/lynr'
require './lib/lynr/logging'

namespace :lynr do

  include Lynr::Logging

  @logger = Log4r::Logger.new('lynr:bootstrap')
  @logger.outputters << Log4r::StdoutOutputter.new("console", OPTS)

  env = Lynr.env

  desc 'Does one-time setup of local Lynr environment'
  task :bootstrap => [:'bootstrap:config', :'bootstrap:certs']

  desc 'Copy example configuration files based on environment'
  task :'bootstrap:config' => [ "config/app.#{env}.yaml",
                                "config/database.#{env}.yaml",
                                "config/features.#{env}.yaml", ] do
    log.info 'Finished lynr:bootstrap:config'
  end

  file "config/app.#{env}.yaml" do
    execute_commands(["cp config/app.{example,#{env}}.yaml"])
    log.warn "** You need to edit `config/app.#{env}.yaml` for a fully functioning application. **"
  end

  file "config/database.#{env}.yaml" do
    execute_commands(["cp config/database.{example,#{env}}.yaml"])
  end

  file "config/features.#{env}.yaml" do
    execute_commands(["cp config/features.{example,#{env}}.yaml"])
  end

  desc 'Generate self-signed certificates and put them in certs'
  task :'bootstrap:certs' => [ "certs/server.cert.key",
                               "certs/server.cert.crt", ] do
    log.info 'Finished lynr:bootstrap:certs'
  end

  file "certs/privkey.pem" do
    execute_commands([
      "openssl req -new -passin pass:hithere -passout pass:hithere\
        -subj '/CN=lynr.co.local/O=Lynr, LLC/C=US/ST=CA/L=Los Angeles'\
        -keyout certs/privkey.pem -out certs/server.cert.csr",
    ])
  end

  file "certs/server.cert.key" => ["certs/privkey.pem"] do
    execute_commands([
      "openssl rsa -passin pass:hithere -in certs/privkey.pem -out certs/server.cert.key",
    ])
  end

  file "certs/server.cert.crt" => ["certs/server.cert.key"] do
    execute_commands([
      "openssl x509 -req -days 365 -in certs/server.cert.csr\
        -out certs/server.cert.crt\
        -signkey certs/server.cert.key",
    ])
  end

  def execute_commands(commands)
    commands.map do |cmd|
      log.info "`#{cmd}`"
      `#{cmd}`
    end
  end

end
