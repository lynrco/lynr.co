require 'libxml'

require './lib/lynr/converter/libxml_helper'
require './lib/lynr/model/mpg'
require './lib/lynr/model/vehicle'
require './lib/lynr/model/vin'

module Lynr; module Converter;

  # # `Lynr::Converter::DataOne`
  #
  # Module to convert XML from DataOne (VIN search) into `Lynr::Model`
  # instances.
  #
  module DataOne

    include Lynr::Converter::LibXmlHelper

    # ## `#xml_to_vehicle(query_response)`
    #
    # Take a `<query_response />` `LibXML::XML::Node` and create a
    # `Lynr::Model::Vehicle` instance containing the data from `query_response`.
    # Returns an empty vehicle if no `query_response` is provided.
    #
    def xml_to_vehicle(query_response)
      return Lynr::Model::Vehicle.new if query_response.nil?
      us_data = query_response.find_first('.//us_market_data/common_us_data')
      Lynr::Model::Vehicle.new({
        'price' => content(us_data, './pricing/msrp'),
        'mpg' => xml_to_mpg(query_response),
        'vin' => xml_to_vin(query_response)
      })
    end

    # ## `#xml_to_mpg(query_response)`
    #
    # Take a `<query_response />` `LibXML::XML::Node` and create a
    # `Lynr::Model::Mpg` instance containing its data. Returns an empty `Mpg`
    # instance if `query_response` is `nil`.
    #
    def xml_to_mpg(query_response)
      return Lynr::Model::Mpg.new if query_response.nil?
      us_data = query_response.find_first('.//us_market_data/common_us_data')
      Lynr::Model::Mpg.new({
        'city'    => content(us_data, './/epa_fuel_efficiency/epa_mpg_record/city'),
        'highway' => content(us_data, './/epa_fuel_efficiency/epa_mpg_record/highway')
      })
    end

    # ## `#xml_to_vin(query_response)`
    #
    # Take a `<query_response />` `LibXML::XML::Node` and create a
    # `Lynr::Model::Vin` instance containing its data. Returns an empty `Vin`
    # instance if `query_response` is `nil`.
    #
    def xml_to_vin(query_response)
      return Lynr::Model::Vin.inflate(nil) if query_response.nil?
      us_data = query_response.find_first('.//us_market_data/common_us_data')
      basic_data = query_response.find_first('.//us_market_data/common_us_data/basic_data')
      Lynr::Model::Vin.new(
        'year' => content(basic_data, './year'),
        'make' => content(basic_data, './make'),
        'model' => get_model(basic_data),
        'transmission' => content(us_data, './/transmission/type'),
        'fuel' => content(us_data, './/fuel_type'),
        'doors' => content(us_data, './/doors'),
        'drivetrain' => content(us_data, './/drive_type'),
        'number' => query_response['identifier'],
        'raw' => query_response.to_s
      )
    end

    # ## `#get_model(basic_data)`
    #
    # Take a `<basic_data />` node and get the model and trip information
    # and join them together.
    #
    def get_model(basic_data)
      [ content(basic_data, './model'),
        content(basic_data, './trim')
      ].join(' ').strip
    end

    # ## `#get_color_data(us_data, type)`
    #
    # Get color information out of `<us_data />` node for `type`, where
    # `type` is 'ext' or 'int' and join them into one string.
    #
    def get_color_data(us_data, type)
      contents(us_data, ".//#{type}erior_colors//generic_color_name").join(', ')
    end

  end

end; end;
