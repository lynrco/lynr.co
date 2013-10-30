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

    def self.inflate_xml(query_response)
      base = '//us_market_data/common_us_data'
      ext_colors = REXML::XPath.match(query_response, "#{base}//exterior_colors//generic_color_name").map { |el| el.text }
      int_colors = REXML::XPath.match(query_response, "#{base}//interior_colors//generic_color_name").map { |el| el.text }
      Lynr::Model::Vin.new(
        REXML::XPath.match(query_response, "#{base}//transmission/@name").map { |n| n.value }.first,
        REXML::XPath.match(query_response, "#{base}//fuel_type").map { |n| n.text }.first,
        REXML::XPath.match(query_response, "#{base}//doors").map { |n| n.text }.first,
        REXML::XPath.match(query_response, "#{base}//drive_type").map { |n| n.text }.first,
        (ext_colors.length <= 1 && ext_colors.first) || ext_colors.join(', '),
        (int_colors.length <= 1 && int_colors.first) || int_colors.join(', '),
        query_response.attribute('identifier').value,
        query_response.to_s
      )
    end

  end

end; end;
