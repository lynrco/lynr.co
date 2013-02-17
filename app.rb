require 'bundler/setup'
require 'log4r'
require 'sinatra'

module Quicklist

  class App < Sinatra::Application

    ROOT = '/api'
    VERSION = 'v1'
    BASE = "#{ROOT}/#{VERSION}"

    enable :logging

    set :public_folder, File.dirname(__FILE__) + '/public'
    set :views, File.dirname(__FILE__) + '/views'

    get '/' do
    end

    def self.log
      Log4r::Logger['api_log'] || create_log('api_log')
    end

    def self.create_log(log_name)
      log = Log4r::Logger.new log_name
      log.outputters = Log4r::Outputter.stdout
      log
    end

  end

end

Quicklist::App.log.info 'App Started'
