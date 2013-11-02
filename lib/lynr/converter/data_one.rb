require 'libxml'

require './lib/lynr/converter/libxml_helper'
require './lib/lynr/model/mpg'
require './lib/lynr/model/vehicle'
require './lib/lynr/model/vin'

module Lynr; module Converter;

  class DataOne < LibXmlHelper

    def self.xml_to_vehicle(query_response)
      return Lynr::Model::Vehicle.new if query_response.nil?
      us_data = query_response.find('.//us_market_data/common_us_data').first
      Lynr::Model::Vehicle.new({
        'year' => contents(us_data, './basic_data/year').first,
        'make' => contents(us_data, './basic_data/make').first,
        'model' => contents(us_data, './basic_data/model').first,
        'price' => contents(us_data, './pricing/msrp').first,
        'mpg' => xml_to_mpg(query_response),
        'vin' => xml_to_vin(query_response)
      })
    end

    def self.xml_to_mpg(query_response)
      return Lynr::Model::Mpg.new if query_response.nil?
      us_data = query_response.find('.//us_market_data/common_us_data').first
      Lynr::Model::Mpg.new({
        'city'    => contents(us_data, './/epa_fuel_efficiency/epa_mpg_record/city').first,
        'highway' => contents(us_data, './/epa_fuel_efficiency/epa_mpg_record/highway').first
      })
    end

    def self.xml_to_vin(query_response)
      return Lynr::Model::Vin.inflate(nil) if query_response.nil?
      us_data = query_response.find('.//us_market_data/common_us_data').first
      ext_colors = (contents(us_data, './/exterior_colors//generic_color_name')) || []
      int_colors = (contents(us_data, './/interior_colors//generic_color_name')) || []
      Lynr::Model::Vin.new(
        values(us_data, './/transmission/@name').first,
        contents(us_data, './/fuel_type').first,
        contents(us_data, './/doors').first,
        contents(us_data, './/drive_type').first,
        (ext_colors.length >= 1 && ext_colors.join(', ')) || ext_colors.first,
        (int_colors.length >= 1 && int_colors.join(', ')) || int_colors.first,
        query_response['identifier'],
        query_response.to_s
      )
    end

  end

end; end;

module LibXML; module XML;

  class Node

    def to_vin
      raise Exception.new if self.name != 'query_response'
      Lynr::Converter::DataOne.xml_to_vin(self)
    end

    def to_mpg
      raise Exception.new if self.name != 'query_response'
      Lynr::Converter::DataOne.xml_to_mpg(self)
    end

  end

end; end;
