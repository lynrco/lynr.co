require 'libxml'

require './lib/lynr/model/base'

module Lynr; module Model;

  class Vin

    include Base

    ATTRS = [ :number, :raw,
              :doors, :drivetrain, :ext_color, :fuel, :int_color, :make, :model,
              :transmission, :year
            ]

    def initialize(data={})
      properties = data.dup
      properties.delete_if { |k, v| v.is_a?(String) && v.empty? }
      @data = properties
    end

    def method_missing(name, *args, &block)
      if args.size == 0 && block.nil? && (ATTRS.include?(name.to_sym))
        @data.fetch(name.to_s, default=nil)
      else
        super
      end
    end

    def respond_to_missing?(sym, include_private)
      super || ATTRS.include?(sym)
    end

    def view
      Hash[ ATTRS.map { |key| [key.to_s, @data.fetch(key.to_s, default=nil)] } ]
    end

    def self.inflate(record)
      data = record || {}
      Lynr::Model::Vin.new(data)
    end

    private

    def equality_fields
      [:doors, :drivetrain, :ext_color, :fuel, :int_color, :make, :model, :transmission, :year]
    end

  end

end; end;
