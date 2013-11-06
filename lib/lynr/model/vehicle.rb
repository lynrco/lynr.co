require 'bson'
require 'kramdown'
require 'libxml'

require './lib/lynr/model/base'
require './lib/lynr/model/base_dated'
require './lib/lynr/model/dealership'
require './lib/lynr/model/sized_image'
require './lib/lynr/model/mpg'
require './lib/lynr/model/vin'

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
  # * `:images`, an `Array` of `Lynr::Model::SizedImage` objects.
  # * `:dealership`, a `Lynr::Model::Dealership` instance
  class Vehicle

    include Lynr::Model::Base
    include Lynr::Model::BaseDated

    attr_reader :id, :dealership, :created_at, :updated_at
    attr_reader :year, :make, :model, :price, :condition, :mpg, :vin, :notes

    def initialize(data={}, id=nil)
      data.default_proc = proc do |hash, key|
        data[key] = Vehicle.defaults[key]
      end
      @id = id
      @year = data['year']
      @make = data['make']
      @model = data['model']
      @name = "#{@year} #{@make} #{@model}".strip
      @price = data['price']
      @condition = data['condition']
      @mpg = data['mpg'] # Should be an instance of Lynr::Model::Mpg
      @vin = data['vin'] # Should be an instance of Lynr::Model::Vin
      @images = data['images']
      @dealership = (data['dealership'].is_a?(Lynr::Model::Dealership) && data['dealership']) || nil
      @dealership_id = data['dealership'] if @dealership.nil?
      @notes = data['notes']
      @created_at = data['created_at']
      @updated_at = data['updated_at']
      @deleted_at = data['deleted_at']
    end

    def dealership_id
      (@dealership && @dealership.id) || @dealership_id
    end

    def image
      images.first || Lynr::Model::Image::Empty
    end

    def images
      @images.reject { |img| img.nil? || img == Lynr::Model::Image::Empty }
    end

    def images?
      !self.image.empty?
    end

    def name
      (!@name.strip.empty? && @name) || "N/A"
    end

    def notes_html
      Kramdown::Document.new(@notes).to_html
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
      data['images'] = data['images'].map { |image| Lynr::Model::SizedImage.inflate(image) } if data['images']
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
        'notes' => @notes,
        'dealership' => @dealership,
        'created_at' => @created_at,
        'updated_at' => @updated_at,
        'deleted_at' => @deleted_at
      }
    end

    private

    # Defines the defaults for the data `Hash` passed in for `#initialize`
    def self.defaults
      {
        'mpg' => Lynr::Model::Mpg.new,
        'vin' => Lynr::Model::Vin.inflate(nil),
        'images' => [],
        'notes' => ''
      }
    end

  end

end; end;
