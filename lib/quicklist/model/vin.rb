require './lib/quicklist/model/base'

module Quicklist; module Model;

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
      @number = number
      @raw = raw
    end

    def view
      {
        transmission: @transmission,
        fuel: @fuel,
        doors: @doors,
        drivetrain: @drivetrain,
        ext_color: @ext_color,
        int_color: @int_color,
        number: @number
      }
    end

  end

end; end;
