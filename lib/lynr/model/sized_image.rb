require './lib/lynr/model/base'
require './lib/lynr/model/image'

module Lynr; module Model;

  # # `Lynr::Model::SizedImage`
  #
  # Representation of an `Image` with multiple sizes. `SizedImage` is composed
  # of three separate `Image` instances. One `Image` instance is designated as the
  # primary `Image` and its values are used as the `url`, `height` and `width` of
  # `SizedImage`.
  #
  class SizedImage

    include Base

    attr_reader :original, :full, :thumb

    def initialize(data={})
      @original = data.fetch('original', default=Image::Empty)
      @full = data.fetch('full', default=Image::Empty)
      @thumb = data.fetch('thumb', default=Image::Empty)
      @primary = [@original, @full, @thumb].find { |img| !img.empty? } || Image::Empty
    end

    # ## `SizedImage#empty?`
    #
    # A `SizedImage` is empty if all three of its backing `Image` instances are
    # empty.
    #
    def empty?
      @original.empty? && @full.empty? && @thumb.empty?
    end

    def height
      @primary.height
    end

    def url
      @primary.url
    end

    def view
      {
        'original' => @original.view,
        'full'     => @full.view,
        'thumb'    => @thumb.view
      }
    end

    def width
      @primary.width
    end

    def self.inflate(record)
      record = Lynr::Model::SizedImage.normalize_record(record)
      Lynr::Model::SizedImage.new(record)
    end

    # ## `SizedImage::Empty`
    #
    # "Singleton" representation of an empty image.
    #
    Empty = Lynr::Model::SizedImage.new

    private

    # ## `SizedImage.normalize_record(record)`
    #
    # If `record` can be inflated into an `Image` instance, do so and set the new
    # instance as `@original` otherwise make sure the values for the sizes of images
    # are `Image` instances.
    #
    def self.normalize_record(record)
      record = {} if record.nil?
      if Lynr::Model::Image.inflatable?(record)
        { 'original' => Lynr::Model::Image.inflate(record) }
      else
        Hash[record.map { |k,v|
          if v.respond_to?(:keys) && Lynr::Model::Image.inflatable?(v)
            [k, Lynr::Model::Image.inflate(v)]
          else
            [k, v]
          end
        }]
      end
    end

  end

end; end;
