require 'libxml'

require './lib/lynr/model/base'

module Lynr; module Model;

  class Vin

    include Base

    attr_reader :number, :raw
    attr_reader :doors, :drivetrain, :ext_color, :fuel, :int_color, :make, :model,\
                :transmission, :year

    def initialize(data={})
      @doors = data.fetch('doors', default=nil)
      @drivetrain = data.fetch('drivetrain', default=nil)
      @ext_color = data.fetch('ext_color', default=nil)
      @fuel = data.fetch('fuel', default=nil)
      @int_color = data.fetch('int_color', default=nil)
      @make = data.fetch('make', default=nil)
      @model = data.fetch('model', default=nil)
      @transmission = data.fetch('transmission', default=nil)
      @year = data.fetch('year', default=nil)

      @data = data
      @number = data.fetch('number', default=nil)
      @raw = data.fetch('raw', default=nil)
    end

    def view
      {
        'doors' => @doors,
        'drivetrain' => @drivetrain,
        'ext_color' => @ext_color,
        'fuel' => @fuel,
        'int_color' => @int_color,
        'make' => @make,
        'model' => @model,
        'transmission' => @transmission,
        'year' => @year,
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
      [:doors, :drivetrain, :ext_color, :fuel, :int_color, :make, :model, :transmission, :year]
    end

  end

end; end;
