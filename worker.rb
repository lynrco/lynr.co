require 'bundler/setup'
require 'bunny'

require 'lynr'
require 'lynr/config'
require 'lynr/logging'

module Lynr

  class Worker

    include Lynr::Logging

    @app = false

    attr_reader :config

    def initialize(queue_name)
      @config = Lynr::Config.new('app', ENV['whereami'])
      @consumer = Lynr::Queue.new(queue_name, @config['amqp']['consumer'])
    end

    def call
      @consumer.subscribe &method(:handle)
    end

    private

    def handle(delivery_info, metadata, payload)
      case metadata.content_type
      when "application/yaml": handleYaml(payload)
      when "application/json": handleJson(payload)
      when "application/binary": handleBinary(payload)
      else
        log.warn("Unknown message: #{payload}")
      end
    end

    def handleBinary(payload)
      job = Marshal::load(payload)
      execute(job)
    end

    def handleJson(payload)
    end

    def handleYaml(payload)
      job = YAML::load(payload)
      execute(job)
    end

    def execute(job)
      job.perform if job.respond_to? :perform
    end

  end

end
