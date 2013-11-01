require 'libxml'

require './lib/lynr/model/base'

module Lynr; module Model;

  class Vin

    include Base

    attr_reader :number, :raw
    attr_reader :transmission, :fuel, :doors, :drivetrain, :ext_color, :int_color

    def initialize(transmission, fuel, doors, drivetrain, ext_color, int_color, number="", raw="")
      @transmission = transmission
      @fuel = fuel
      @doors = doors
      @drivetrain = drivetrain
      @ext_color = ext_color
      @int_color = int_color
      @number = number || ""
      @raw = raw || ""
    end

    def view
      {
        'transmission' => @transmission,
        'fuel' => @fuel,
        'doors' => @doors,
        'drivetrain' => @drivetrain,
        'ext_color' => @ext_color,
        'int_color' => @int_color,
        'number' => @number
      }
    end

    def self.inflate(record)
      data = record || {}
      Lynr::Model::Vin.new(
        data['transmission'],
        data['fuel'],
        data['doors'],
        data['drivetrain'],
        data['ext_color'],
        data['int_color'],
        data['number'],
        data['raw']
      )
    end

  end

end; end;
