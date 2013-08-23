require 'lynr/model/base'
require 'lynr/model/base_dated'
require 'lynr/model/dealership'
require 'lynr/model/image'
require 'lynr/model/mpg'
require 'lynr/model/vin'

module Lynr; module Model;

  # This is the primary object of the Application. Most of the data retrieval
  # will result in Vehicle objects.
  #
  # `Vehicle.new` takes a `Hash` containing specific data properties to set.
  #
  # * `:year`, `String` car year
  # * `:make`, `String` car make
  # * `:model`, `String` car model
  # * `:price`, an integer price in whole dollars (USD)
  # * `:condition`, an integer from 0-5, inclusive, representing condition of the
  #   vehicle. 0 indicates no rating
  # * `:mpg`, a `Lynr::Model::Mpg` object containing information about highway
  #   and city mileage information.
  # * `:vin`, a `Lynr::Model::Vin` object containing all the information
  #   that would be retrieved with a vin lookup. The object may or may not contain
  #   the actual vin number.
  # * `:images`, an `Array` of `Lynr::Model::Image` objects.
  # * `:dealership`, a `Lynr::Model::Dealership` instance
  class Vehicle

    include Lynr::Model::Base
    include Lynr::Model::BaseDated

    attr_reader :id, :dealership, :created_at, :updated_at
    attr_reader :year, :make, :model, :price, :condition, :mpg, :vin, :images

    def initialize(data={}, id=nil)
      @id = id
      @year = data['year'] || ""
      @make = data['make'] || ""
      @model = data['model'] || ""
      @name = "#{@year} #{@make} #{@model}".strip
      @price = data['price'] || 0.0
      @condition = data['condition'] || 0
      @mpg = data['mpg'] || nil # Should be an instance of Lynr::Model::Mpg
      @vin = data['vin'] || nil # Should be an instance of Lynr::Model::Vin
      @images = data['images'] || []
      @dealership = (data['dealership'].is_a?(Lynr::Model::Dealership) && data['dealership']) || nil
      @dealership_id = data['dealership'] if @dealership.nil?
      @created_at = data['created_at']
      @updated_at = data['updated_at']
    end

    def dealership_id
      (@dealership && @dealership.id) || @dealership_id
    end

    def image
      images.compact.shift || Lynr::Model::Image.new
    end

    def name
      (!@name.strip.empty? && @name) || "N/A"
    end

    def set(data)
      Lynr::Model::Vehicle.new(self.to_hash.merge(data), @id)
    end

    def slug
      id.to_s
    end

    # `Vehicle#view` is essentially the opposite of `Vehicle.inflate`. It
    # operates on the current Vehicle and deflates it down to a `Hash` of
    # properties.
    def view
      data = self.to_hash
      data['images'] = @images.map { |image| image.view }
      data['mpg'] = @mpg.view if (@mpg)
      data['vin'] = @vin.view if (@vin)
      data['dealership'] = @dealership.id if (@dealership.respond_to?(:id))
      data
    end

    # `Vehicle.inflate` takes a database record and inflates the properties
    # into Lynr objects to be used elsewhere
    def self.inflate(record)
      record ||= {}
      data = record.dup
      data['mpg'] = Lynr::Model::Mpg.inflate(data['mpg']) if data['mpg']
      data['vin'] = Lynr::Model::Vin.inflate(data['vin']) if data['vin']
      data['images'] = data['images'].map { |image| Lynr::Model::Image.inflate(image) } if data['images']
      Lynr::Model::Vehicle.new(data, data['id'])
    end

    protected

    def to_hash
      {
        'year' => @year,
        'make' => @make,
        'model' => @model,
        'price' => @price,
        'condition' => @condition,
        'images' => @images,
        'mpg' => @mpg,
        'vin' => @vin,
        'dealership' => @dealership,
        'created_at' => @created_at,
        'updated_at' => @updated_at
      }
    end

  end

end; end;
