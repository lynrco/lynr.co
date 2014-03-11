require 'libxml'

require './lib/lynr/model/base'

module Lynr::Model

  # # `Lynr::Model::Vin`
  #
  # Class to represent the critical data which can be gleaned from a VIN decoding.
  # The VIN encodes a surprising amount of information about a vehicle and this
  # class is meant to provide a high signal subset of the data in a VIN. The properties
  # accessible from `Lynr::Model::Vin` are listed in `Vin::ATTRS` and each property
  # has a default value of `nil`.
  #
  class Vin

    include Base

    # ## `Vin::ATTRS`
    #
    # `Array` of high signal fields from the VIN data.
    #
    ATTRS = [ :number, :raw,
              :doors, :drivetrain, :ext_color, :fuel, :int_color, :make, :model,
              :transmission, :year
            ]

    # ## `Vin.new(data)`
    #
    # Remove empty Strings from `data` but otherwise store it as is as the
    # backing structure for this instance.
    #
    def initialize(data={})
      properties = data.dup
      properties.delete_if { |k, v| v.is_a?(String) && v.empty? }
      @data = properties
    end

    # ## `Vin#method_missing(name, *args, &block)`
    #
    # Implement Ruby 'magic' method to allow access to values contained in
    # data provided the keys are in `Vin::ATTRS` as `Symbols`.
    #
    def method_missing(name, *args, &block)
      if args.size == 0 && block.nil? && (ATTRS.include?(name.to_sym))
        @data.fetch(name.to_s, default=nil)
      else
        super
      end
    end

    # ## `Vin#respond_to_missing?(sym, include_private)`
    #
    # A `#respond_to?` extension allowing this class to tell others what it messages
    # it will have a response to based on `Vin::ATTRS`.
    #
    def respond_to_missing?(sym, include_private)
      super || ATTRS.include?(sym)
    end

    # ## `Vin#set(properties)`
    #
    # Merge existing `@data` with `properties` and create a new `Vin` instance
    # with the resulting data.
    #
    def set(properties)
      Vin.new(@data.merge(properties))
    end

    # ## `Vin#view`
    #
    # Provide a view of properties in backing `@data` with non-existent values
    # filled in as `nil`.
    #
    def view
      Hash[ ATTRS.map { |key| [key.to_s, @data.fetch(key.to_s, default=nil)] } ]
    end

    # ## `Vin.inflate(record)`
    #
    # Safely create a new `Vin` instance even if record is `nil`.
    #
    def self.inflate(record)
      data = record || {}
      Lynr::Model::Vin.new(data)
    end

    private

    # ## `Vin#equality_fields`
    #
    # Describe to `Lynr::Model::Base` how to determine equality between two `Vin`
    # instances.
    #
    def equality_fields
      [:doors, :drivetrain, :ext_color, :fuel, :int_color, :make, :model, :transmission, :year]
    end

  end

end
