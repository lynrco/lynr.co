# Defines tasks to start web application for local development

namespace :lynr do

  def load_env(path)
    if File.exists?(path) && File.readable?(path)
      File.readlines(path).each do |line|
        parts = line.chomp.split('=')
        ENV[parts[0]] = parts[1]
      end
    end
  end

  def server_and_options
    load_env(File.join(Lynr.root, '.env'))
    load_env(File.join(Lynr.root, ".env.#{Lynr.env}"))

    ENV['SSL_CERT_FILE'] = "#{File.dirname(__FILE__).chomp('/task')}/certs/server.cert.crt"
    ENV['SSL_CERT_DIR'] = "#{File.dirname(__FILE__).chomp('/task')}/certs"

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

    # `openssl req -new > server.cert.csr`
    # `openssl rsa -in privkey.pem -out server.cert.key`
    # `openssl x509 -in server.cert.csr -out server.cert.crt -req -signkey server.cert.key -days 365`
    pkey = OpenSSL::PKey::RSA.new(File.open("#{Lynr.root}/certs/server.cert.key").read)
    cert = OpenSSL::X509::Certificate.new(File.open("#{Lynr.root}/certs/server.cert.crt").read)

    options = options.merge({
      SSLEnable: true,
      SSLCertificate: cert,
      SSLPrivateKey: pkey,
  #     SSLVerifyClient: OpenSSL::SSL::VERIFY_NONE,
    })

    [server, options]
  end

  task :local => :shotgun

  desc 'Starts the Lynr application using Shotgun'
  task :shotgun do
    server, options = server_and_options

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

    # load shotgun.rb in current working directory if it exists
    Shotgun.preload

    server.run app, options
  end

  desc 'Starts the Lynr application using stock WEBrick'
  task :webrick do
    server, options = server_and_options

    app = Rack::Builder.parse_file("config.ru")[0]

    server.run app, options
  end

  task :'webrick:nossl' do
    server, options = server_and_options
    options[:SSLEnable] = false

    app = Rack::Builder.parse_file("config.ru")[0]

    server.run app, options
  end

end
