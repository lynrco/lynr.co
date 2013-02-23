require 'bundler/setup'
require 'sinatra/base'

require './lib/quicklist/logger'

module Quicklist

  class App < Sinatra::Base

    include Quicklist::Logging

    ROOT = '/api'
    VERSION = 'v1'
    BASE = "#{ROOT}/#{VERSION}"

    enable :logging

    set :public_folder, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/views'

    get '/' do
      log.info 'Requested /'
      erb :index
    end


  end

end
