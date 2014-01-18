require 'libxml'

require './lib/lynr/model/base'

module Lynr; module Model;

  # # `Lynr::Model::Mpg`
  #
  # Representation for miles per gallon information of a vehicle in different
  # conditions.
  #
  class Mpg

    include Base

    attr_reader :city, :highway

    # ## `Mpg.new(data)`
    #
    # Extract values from `data` to store.
    #
    # * `city` is the MPG rating for a vehicle in city condtions
    # * `highway` is the MPG rating for a vehicle in highway conditions
    #
    def initialize(data={})
      @city = data['city'] || 0.0
      @highway = data['highway'] || 0.0
    end

    def view
      { 'city' => @city, 'highway' => @highway }
    end

    # ## `Mpg.inflate`
    #
    # Transform a DB `record` into something `Mpg.new` will understand then
    # return `Mpg.new`.
    #
    def self.inflate(record)
      data = record || {}
      Lynr::Model::Mpg.new(data)
    end

  end

end; end;
