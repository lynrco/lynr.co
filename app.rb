require 'bundler/setup'
require 'sinatra/base'

require './lib/lynr/logging'
require './lib/lynr/controller/root'

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

    set :root, File.dirname(__FILE__)
    set :public_folder, settings.root + '/public'
    set :views, settings.root + '/views'

    # Call `use Lynr::ControllerName` to use routes from other class definitions
    use Lynr::Controller::Root

  end

end
