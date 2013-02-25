require 'bundler/setup'
require 'sinatra/base'

require './lib/lynr/logging'

module Lynr

  class App < Sinatra::Base

    include Lynr::Logging

    ROOT = '/api'
    VERSION = 'v1'
    BASE = "#{ROOT}/#{VERSION}"

    enable :logging

    # taken from https://groups.google.com/d/msg/sinatrarb/lwd419mimJA/aptlwC5QJG4J
    #error do
    #  e = @env['sinatra.error']
    #  [ halt 500, { 'Content-Type' => 'text/plain' }, "Internal Server Error - #{e.message}\n"
    #end

    # For request logging write Rack middleware that replaces env['rack.errors'] and env['rack.logger']
    # This will likely require `enable :logging` to have it work

    set :public_folder, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/views'

    get '/' do
      log.info 'Requested /'
      erb :index
    end

    # Call `use Lynr::ControllerName` to use routes from other class definitions

  end

end
