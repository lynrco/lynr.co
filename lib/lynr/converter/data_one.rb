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
      us_data = query_response.find('.//us_market_data/common_us_data').first
      Lynr::Model::Vehicle.new({
        'price' => contents(us_data, './pricing/msrp').first,
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
      us_data = query_response.find('.//us_market_data/common_us_data').first
      Lynr::Model::Mpg.new({
        'city'    => contents(us_data, './/epa_fuel_efficiency/epa_mpg_record/city').first,
        'highway' => contents(us_data, './/epa_fuel_efficiency/epa_mpg_record/highway').first
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
      us_data = query_response.find('.//us_market_data/common_us_data').first
      basic_data = us_data.find('./basic_data').first unless us_data.nil?
      ext_colors = contents(us_data, './/exterior_colors//generic_color_name')
      int_colors = contents(us_data, './/interior_colors//generic_color_name')
      model = [
        contents(basic_data, './model').first,
        contents(basic_data, './trim').first
      ].join(' ').strip
      Lynr::Model::Vin.new(
        'year' => contents(basic_data, './year').first,
        'make' => contents(basic_data, './make').first,
        'model' => (model unless model.nil? || model.empty?),
        'transmission' => values(us_data, './/transmission/@name').first,
        'fuel' => contents(us_data, './/fuel_type').first,
        'doors' => contents(us_data, './/doors').first,
        'drivetrain' => contents(us_data, './/drive_type').first,
        'ext_color' => (ext_colors.length >= 1 && ext_colors.join(', ')) || ext_colors.first,
        'int_color' => (int_colors.length >= 1 && int_colors.join(', ')) || int_colors.first,
        'number' => query_response['identifier'],
        'raw' => query_response.to_s
      )
    end

  end

end; end;
