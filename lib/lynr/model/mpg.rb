require 'libxml'

require './lib/lynr/model/base'

module Lynr; module Model;

  class Mpg

    include Base

    attr_reader :city, :highway

    def initialize(data={})
      @city = data['city'] || 0.0
      @highway = data['highway'] || 0.0
    end

    def view
      { 'city' => @city, 'highway' => @highway }
    end

    def self.inflate(record)
      data = record || {}
      Lynr::Model::Mpg.new(data)
    end

    def self.inflate_xml(query_response)
      return Lynr::Model::Mpg.new if query_response.nil?
      us_data = query_response.find('.//us_market_data/common_us_data').first
      Lynr::Model::Mpg.new({
        'city'    => us_data && us_data.find('.//epa_fuel_efficiency/epa_mpg_record/city').map { |n| n.content }.first,
        'highway' => us_data && us_data.find('.//epa_fuel_efficiency/epa_mpg_record/highway').map { |n| n.content }.first
      })
    end

  end

end; end;
