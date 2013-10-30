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

    def self.inflate_xml(query_response)
      return Lynr::Model::Vin.inflate(nil) if query_response.nil?
      us_data = query_response.find('.//us_market_data/common_us_data').first
      ext_colors = (us_data && us_data.find('.//exterior_colors//generic_color_name').map { |el| el.content }) || []
      int_colors = (us_data && us_data.find('.//interior_colors//generic_color_name').map { |el| el.content }) || []
      Lynr::Model::Vin.new(
        us_data && us_data.find('.//transmission/@name').map { |n| n.value }.first,
        us_data && us_data.find('.//fuel_type').map { |n| n.content }.first,
        us_data && us_data.find('.//doors').map { |n| n.content }.first,
        us_data && us_data.find('.//drive_type').map { |n| n.content }.first,
        (ext_colors.length >= 1 && ext_colors.join(', ')) || ext_colors.first,
        (int_colors.length >= 1 && int_colors.join(', ')) || int_colors.first,
        query_response['identifier'],
        query_response.to_s
      )
    end

  end

end; end;
