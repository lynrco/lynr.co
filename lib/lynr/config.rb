require 'json'
require 'yaml'

require './lib/lynr'

module Lynr

  # # `Lynr::Config`
  #
  # The `Config` class is composed of a type, an environment name and an optional
  # set of default values. Config is intended as a convenience wrapper around
  # `Hash` so properties can be accessed by dot notation `config.mailgun` instead
  # of `config['mailgun']` and to provide a standard default value of `nil`.
  # Additionally properties with a `String` values with an 'env:' prefix will cause
  # `Config` to look  in the `ENV` `Hash` for a value rather than returning the
  # 'env:' value from the configuration file.
  #
  class Config

    attr_reader :environment, :type

    Transforms = [
      {
        test: lambda { |v, d| v.is_a?(String) && v.start_with?('env:') },
        rule: lambda { |v, d| ENV[v.sub(%r(^env:), '')] },
      },
      {
        test: lambda { |v, d| v.is_a?(Hash) },
        rule: lambda { |v, d| Config.new(type=nil, whereami=nil, config=v) },
      },
      {
        test: lambda { |v, d| (d.class == TrueClass || d.class == FalseClass) },
        rule: lambda { |v, d| Config.bool(v) },
      },
    ]

    # ## `Lynr::Config.new(type, whereami, defaults)`
    #
    # Create a new `Config` based on `type` and `whereami` with default values from
    # `defaults`. By default `Config` looks for a .yaml file in the 'config' directury,
    # relative to `Lynr.root`, with the form `"#{Lynr.root}/config/#{type}.#{whereami}.yaml"`.
    # If the file exists it is loaded and merged into `defaults` recursively.
    #
    def initialize(type, whereami='development', defaults={})
      @type = type
      @environment = whereami || 'development'
      @config = defaults || {}
      merge_external if has_external?
    end

    # ## `Lynr::Config#[](key)`
    #
    # Alias for `Lynr::Config#fetch(key, nil)`
    #
    def [](key)
      fetch(key)
    end

    # ## `Lynr::Config#fetch(key, default)
    #
    # Retrieve a value from the backing data by `key`. Backing data is probed for
    # `key` as a String and a Symbol. If value of `key` is a String with a prefix
    # of 'env:' the value is read from `ENV`, if value is a `Hash` it returns the
    # `Hash` wrapped as a new `Lynr::Config` instance, if value is `nil` it returns
    # `default`.
    #
    def fetch(key, default = nil)
      val = @config.fetch(key.to_s, @config.fetch(key.to_sym, default))
      apply_transformations(val, default)
    end

    # ## `Lynr::Config#include?(key)`
    #
    # Check to see if this `Config` has a value for `key`.
    #
    def include?(key)
      @config.include?(key.to_s) || @config.include?(key.to_sym)
    end

    # ## `Lynr::Config#method_missing(name, *args, &block)`
    #
    # Implement Ruby 'magic' method to allow access to config properties by using
    # a dot notation rather than using brackets or making explicit calls to fetch.
    # If backing data doesn't include a value for method name invoke `super`.
    #
    def method_missing(name, *args, &block)
      if args.size == 0 && block.nil? && (include?(name))
        fetch(name)
      else
        super
      end
    end

    # ## `Lynr::Config#to_hash`
    #
    # Allow access to the backing data
    #
    def to_hash
      @config.dup
    end

    # ## `Lynr::Config#to_json`
    #
    # Method to transform backing data into a JSON structure.
    #
    def to_json
      @config.to_json
    end

    private

    # ## `Lynr::Config#apply_transformations(value, default)`
    #
    # Execute each of `Lynr::Config::Transforms` for `value` and `default`.
    # Transforms are cumulative so the order in which they are defined matters.
    # Each filter has a `:test` and a `:rule`, if `:test` returns true
    # then `:rule` is applied otherwise `value` is passed along unmodified.
    #
    def apply_transformations(value, default)
      Transforms.reduce(value) do |val, filter|
        if filter[:test].call(val, default) then filter[:rule].call(val, default)
        else val
        end
      end
    end

    # ## `Lynr::Config#bool(val)`
    #
    # Convert a String value into a boolean (`TrueClass` or `FalseClass`)
    # if it is a value that makes sense as a boolean.
    #
    # * True: (true|t|yes|y|1)
    # * False: (false|f|no|n|0) or `nil`
    #
    def self.bool(val)
      val = val.to_s
      return true if val == true || val =~ (/(true|t|yes|y|1)$/i)
      return false if val == false || val.nil? || val =~ (/(false|f|no|n|0)$/i)
      raise ArgumentError.new("invalid value for Boolean: \"#{val}\"")
    end

    # ## `Lynr::Config#external_name`
    #
    # *Private* method to get the name of the file from which to try reading backing
    # data.
    #
    def external_name
      "#{Lynr.root}/config/#{@type}.#{@environment}.yaml"
    end

    # ## `Lynr::Config#has_external?`
    #
    # *Private* method to test if a file with backing data exists for `external_name`.
    def has_external?
      !@type.nil? && !@environment.nil? && ::File.exist?(external_name)
    end

    # ## `Lynr::Config#merge_external`
    #
    # *Private* method to recursively merge external backing data from file into the
    # existing backing data.
    #
    def merge_external
      external = YAML.load_file(external_name)
      @config = external.merge(@config) do |key, externalval, configval|
        if (configval.is_a?(Hash))
          externalval.merge(configval)
        else
          configval
        end
      end
    end

  end

end
