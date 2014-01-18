require 'geo_ruby'
require 'geo_ruby/geojson'
require 'json'

require './lib/lynr/model/base'

module Lynr; module Model;

  # # `Lynr::Model::Address`
  #
  # Represent a street address with data from a `Hash`. Expected fields are:
  #
  # * `line_one` of the street address
  # * `line_two` of the street address
  # * `city` where the address is located
  # * `state` where the address is located
  # * `zip` where the address is located
  # * `geo` data representing a GeoJSON Point for this address
  #
  class Address

    include Base

    attr_reader :line_one, :line_two, :city, :state, :zip, :geo

    alias :postcode :zip

    def initialize(data={})
      @line_one = data.fetch('line_one', default=nil)
      @line_two = data.fetch('line_two', default=nil)
      @city = data.fetch('city', default=nil)
      @state = data.fetch('state', default=nil)
      @zip = data.fetch('zip', default=nil)
      @geo = extract_point(data)
    end

    def view
      data = self.to_hash
      data['geo'] = JSON.parse(@geo.to_json) if !@geo.nil?
      data
    end

    def self.inflate(record)
      record = {} if record.nil?
      Lynr::Model::Address.new(record)
    end

    protected

    def to_hash
      {
        'line_one' => @line_one,
        'line_two' => @line_two,
        'city' => @city,
        'state' => @state,
        'zip' => @zip
      }
    end

    private

    def extract_point(data)
      geo = data.fetch('geo', default=nil)
      if (geo.is_a? GeoRuby::SimpleFeatures::Point) then geo
      elsif (geo.is_a? Hash) then GeoRuby::SimpleFeatures::Point.from_geojson(geo.to_json)
      elsif (geo.is_a? String) then GeoRuby::SimpleFeatures::Point.from_geojson(geo)
      else nil
      end
    end

  end

end; end;
