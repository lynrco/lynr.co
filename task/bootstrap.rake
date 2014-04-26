require 'log4r'
require 'openssl'

require './lib/lynr'
require './lib/lynr/logging'

namespace :lynr do

  include Lynr::Logging

  @logger = Log4r::Logger.new('rake:lynr')
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

  file "config/events.#{env}.yaml" do
    execute_commands(["cp config/events.{example,#{env}}.yaml"])
  end

  desc 'Generate self-signed certificates and put them in vm/certs'
  task :'bootstrap:certs' => [ "vm/certs/server.cert.key",
                               "vm/certs/server.cert.crt",
                               :'bootstrap:hash_certs', ] do
    log.info 'Finished lynr:bootstrap:certs'
  end

  file "vm/certs/privkey.pem" do
    execute_commands([
      "openssl req -new -passin pass:hithere -passout pass:hithere\
        -subj '/CN=lynr.co.local/O=Lynr, LLC/C=US/ST=CA/L=Los Angeles'\
        -keyout vm/certs/privkey.pem -out vm/certs/server.cert.csr",
    ])
  end

  file "vm/certs/server.cert.key" => ["vm/certs/privkey.pem"] do
    execute_commands([
      "openssl rsa -passin pass:hithere -in vm/certs/privkey.pem -out vm/certs/server.cert.key",
    ])
  end

  file "vm/certs/server.cert.crt" => ["vm/certs/server.cert.key"] do
    execute_commands([
      "openssl x509 -req -days 365 -in vm/certs/server.cert.csr\
        -out vm/certs/server.cert.crt\
        -signkey vm/certs/server.cert.key",
    ])
  end

  file "#{OpenSSL::X509::DEFAULT_CERT_DIR}/lynr.co.local.pem" => [ "vm/certs/server.cert.crt" ] do
      log.info <<EOF

***********************************************************************

Asking for root access in order to move the self-signed certificate to
#{OpenSSL::X509::DEFAULT_CERT_DIR}. This is done as part of the process
to avoid intermittent SSL errors like:

    ERROR OpenSSL::SSL::SSLError: SSL_read:: sslv3 alert bad record mac

when serving files locally. This task should only need to be performed
once per machine but you are seeing this message because
'#{OpenSSL::X509::DEFAULT_CERT_DIR}/lynr.co.local.pem' could not be
found.

***********************************************************************
EOF
    execute_commands([
      "sudo cp vm/certs/server.cert.crt #{OpenSSL::X509::DEFAULT_CERT_DIR}/lynr.co.local.pem",
    ])
  end

  task :'bootstrap:hash_certs' => [ "#{OpenSSL::X509::DEFAULT_CERT_DIR}/lynr.co.local.pem" ] do
    hashed = Dir.new(OpenSSL::X509::DEFAULT_CERT_DIR).any? do |filename|
      path = "#{OpenSSL::X509::DEFAULT_CERT_DIR}/#{filename}"
      File.symlink?(path) && File.readlink(path) == "lynr.co.local.pem"
    end
    if !hashed
      log.info <<EOF

***********************************************************************

Asking for root access in order to hash the self-signed certificate.
This must be done in order to avoid intermittent SSL errors like:

    ERROR OpenSSL::SSL::SSLError: SSL_read:: sslv3 alert bad record mac

when serving files locally. This task should only need to be performed
once per machine but you are seeing this message because a hashed file
pointing to the generated certificat could not be found.

***********************************************************************
EOF
      execute_commands([ "sudo c_rehash #{OpenSSL::X509::DEFAULT_CERT_DIR}", ])
    end
  end

  def execute_commands(commands)
    commands.map do |cmd|
      log.info "`#{cmd}`"
      `#{cmd}`
    end
  end

end
