# Defines tasks to start web application for local development

namespace :lynr do

  desc 'Starts the Lynr application for development'
  task :local do
    ENV['SSL_CERT_FILE'] = "#{File.dirname(__FILE__).chomp('/task')}/certs/server.cert.crt"

    require 'bundler/setup'
    require 'openssl'
    require 'rack'
    require 'rack/utils'
    require 'rack/request'
    require 'rack/response'
    require 'rack/lint'
    require 'rack/commonlogger'
    require 'shotgun'
    require 'webrick/https'

    server = Rack::Handler.default
    options = { :Port => 9393, :Host => '127.0.0.1', :AccessLog => [], :Path => '/' }

    app =
      Rack::Builder.new do
        # these middleware run in the master process.
        use Shotgun::SkipFavicon

        # loader forks the child and runs the embedded config followed by the
        # application config.
        run Shotgun::Loader.new('config.ru') {
          use Rack::CommonLogger, STDERR
          use Rack::Lint
        }
      end

    Shotgun.enable_copy_on_write

    # trap exit signals
    downward = false
    [:INT, :TERM, :QUIT].each do |signal|
      trap(signal) do
        Process.exit!(1) if downward
        downward = true
        server.shutdown if server.respond_to?(:shutdown)
        Process.wait rescue nil
        Process.exit(0)
      end
    end

    # load shotgun.rb in current working directory if it exists
    Shotgun.preload

    # `openssl req -new > server.cert.csr`
    # `openssl rsa -in privkey.pem -out server.cert.key`
    # `openssl x509 -in server.cert.csr -out server.cert.crt -req -signkey server.cert.key -days 365`
    pkey = OpenSSL::PKey::RSA.new(File.open("#{Lynr.root}/certs/server.cert.key").read)
    cert = OpenSSL::X509::Certificate.new(File.open("#{Lynr.root}/certs/server.cert.crt").read)

    options = options.merge({
      SSLEnable: true,
      SSLCertificate: cert,
      SSLPrivateKey: pkey,
    })

    server.run app, options
  end

end
