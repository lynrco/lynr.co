require 'bson'
require 'kramdown'
require 'libxml'

require './lib/lynr/model/base'
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

    attr_reader :id, :created_at, :updated_at
    attr_reader :condition, :mileage, :mpg, :notes, :price, :vin

    def initialize(data={}, id=nil)
      @id = id
      @dealership = data['dealership']

      @condition = data['condition']
      @mileage = data['mileage']
      @mpg = data.fetch('mpg') { |k| Mpg.new(data) }
      @notes = data.fetch('notes', default='')
      @price = data['price']
      @vin = data.fetch('vin') { |k| Vin.new(data) }

      @images = data.fetch('images', default=[])

      @created_at = data['created_at']
      @updated_at = data['updated_at']
      @deleted_at = data['deleted_at']
    end

    def dealership_id
      return @dealership_id if !@dealership_id.nil?

      @dealership_id = (@dealership.is_a?(Dealership) && @dealership.id) || @dealership
    end

    def image
      images.first || Image::Empty
    end

    def images
      @images.reject { |img| img.nil? || img == Image::Empty }
    end

    def images?
      !self.image.empty?
    end

    def make
      vin.make unless vin.nil?
    end

    def model
      vin.model unless vin.nil?
    end

    def name
      return @name unless @name.nil?
      name = "#{year} #{make} #{model}".strip
      @name = (!name.strip.empty? && name) || "N/A"
    end

    def notes_html
      Kramdown::Document.new(@notes).to_html
    end

    def set(data)
      Vehicle.new(self.to_hash.merge(data), @id)
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

    def year
      vin.year unless vin.nil?
    end

    # `Vehicle.inflate` takes a database record and inflates the properties
    # into Lynr objects to be used elsewhere
    def self.inflate(record)
      record ||= {}
      data = record.dup
      data['mpg'] = Mpg.inflate(data['mpg']) if data['mpg']
      data['vin'] = Vin.inflate(data['vin']) if data['vin']
      data['images'] = data['images'].map { |image| SizedImage.inflate(image) } if data['images']
      Vehicle.new(data, data['id'])
    end

    protected

    def to_hash
      {
        'condition' => @condition,
        'dealership' => dealership_id,
        'images' => @images,
        'mileage' => @mileage,
        'mpg' => @mpg,
        'notes' => @notes,
        'price' => @price,
        'vin' => @vin,
        'created_at' => @created_at,
        'updated_at' => @updated_at,
        'deleted_at' => @deleted_at
      }
    end

    private

    def equality_fields
      [ :price, :condition, :images, :mileage, :mpg, :vin, :notes, :dealership_id ]
    end

  end

end; end;
