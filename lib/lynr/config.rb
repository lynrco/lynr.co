require 'yaml'

module Lynr

  class Config

    attr_reader :environment, :type

    def initialize(type, whereami='development', config=nil)
      @type = type
      @environment = whereami || 'development'
      @config = config
      @config = YAML.load_file("config/#{type}.#{environment}.yaml") if @config.nil?
    end

    def [](key)
      val = @config[key]
      if (val.is_a?(String) && val.start_with?('env:'))
        val = ENV[val.sub(%r(^env:), '')]
      elsif (val.is_a?(Hash))
        val = Config.new(type=nil, whereami=nil, config=val)
      end
      val
    end

  end

end
