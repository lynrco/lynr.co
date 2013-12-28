require 'yaml'

module Lynr

  class Config

    attr_reader :environment, :type

    def initialize(type, whereami='development', config={})
      @type = type
      @environment = whereami || 'development'
      @config = config
      merge_external if has_external?
    end

    def [](key)
      fetch(key)
    end

    def fetch(key, default = nil)
      val = @config[key.to_s] || @config[key.to_sym]
      if (val.is_a?(String) && val.start_with?('env:'))
        val = ENV[val.sub(%r(^env:), '')]
      elsif (val.is_a?(Hash))
        val = Config.new(type=nil, whereami=nil, config=val)
      elsif val.nil?
        val = default
      end
      val
    end

    def include?(name)
      @config.include?(name.to_s) || @config.include?(name.to_sym)
    end

    def method_missing(name, *args, &block)
      if args.size == 0 && block.nil? && (include?(name))
        fetch(name.to_s) || fetch(name.to_sym)
      else
        super
      end
    end

    def to_json
      @config.to_json
    end

    private

    def external_name
      "config/#{@type}.#{@environment}.yaml"
    end

    def has_external?
      !@type.nil? && !@environment.nil? && ::File.exist?(external_name)
    end

    def merge_external
      external = YAML.load_file(external_name)
      @config = @config.merge(external) do |key, configval, externalval|
        if (configval.is_a?(Hash))
          configval.merge(externalval)
        else
          externalval
        end
      end
    end

  end

end
