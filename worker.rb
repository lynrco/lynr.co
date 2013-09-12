require 'bundler/setup'
require 'bunny'

require 'lynr'
require 'lynr/config'
require 'lynr/logging'

module Lynr

  class Worker

    @app = false

    attr_reader :config

    def initialize
      @config = Lynr::Config.new('app', ENV['whereami'])
    end

    def self.instance
      @app = Lynr::Web.new if !@app
      @app
    end

    def self.config
      instance.config
    end

    Producer = Bunny.new(Lynr::Worker.config['amqp']['producer'])
    Consumer = Bunny.new(Lynr::Worker.config['amqp']['consumer'])

  end

end
