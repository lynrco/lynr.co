require 'yaml'

module Lynr

  class Config

    attr_reader :environment, :type

    def initialize(type, whereami='development', config={})
      @type = type
      @environment = whereami || 'development'
      @config = config
      if !type.nil? && !whereami.nil?
        @config = @config.merge(YAML.load_file("config/#{type}.#{environment}.yaml")) do |key, oldval, newval|
          if (oldval.is_a?(Hash))
            oldval.merge(newval)
          else
            newval
          end
        end
      end
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
