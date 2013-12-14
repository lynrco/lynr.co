require 'libxml'

require './lib/lynr/model/base'

module Lynr; module Model;

  class Vin

    include Base

    attr_reader :number, :raw
    attr_reader :transmission, :fuel, :doors, :drivetrain, :ext_color, :int_color

    def initialize(data={})
      @data = data
      @transmission = data.fetch('transmission', default=nil)
      @fuel = data.fetch('fuel', default=nil)
      @doors = data.fetch('doors', default=nil)
      @drivetrain = data.fetch('drivetrain', default=nil)
      @ext_color = data.fetch('ext_color', default=nil)
      @int_color = data.fetch('int_color', default=nil)
      @number = data.fetch('number', default=nil)
      @raw = data.fetch('raw', default=nil)
    end

    def view
      {
        'transmission' => @transmission,
        'fuel' => @fuel,
        'doors' => @doors,
        'drivetrain' => @drivetrain,
        'ext_color' => @ext_color,
        'int_color' => @int_color,
        'number' => @number,
        'raw' => @raw
      }
    end

    def self.inflate(record)
      data = record || {}
      Lynr::Model::Vin.new(data)
    end

    private

    def equality_fields
      [:transmission, :fuel, :doors, :drivetrain, :ext_color, :int_color]
    end

  end

end; end;
