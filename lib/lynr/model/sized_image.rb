require './lib/lynr/model/base'
require './lib/lynr/model/image'

module Lynr; module Model;

  class SizedImage

    include Base

    attr_reader :original, :full, :thumb

    def initialize(data={})
      @original = data['original'] || Image::Empty
      @full = data['full'] || Image::Empty
      @thumb = data['thumb'] || Image::Empty
      @primary = [@original, @full, @thumb].find { |img| !img.empty? } || Image::Empty
    end

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

    private

    # if given an Image record set the Image as original
    # otherwise make sure the values are Image instances
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
