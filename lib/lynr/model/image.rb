require './lib/lynr/model/base'

module Lynr; module Model;

  # # `Lynr::Model::Image`
  #
  # Representation of an image.
  #
  class Image

    include Base

    attr_reader :width, :height

    def initialize(width=nil, height=nil, url=nil)
      @width = width.to_i
      @height = height.to_i
      @url = url
    end

    # ## `Image#url`
    #
    # URL to the image. `blank.gif` if this instance is `#empty?` a valid URI
    # to an image otherwise.
    #
    def url
      if self.empty?
        "/img/blank.gif"
      else
        @url
      end
    end

    # ## `Image#empty?`
    #
    # An `Image` is considered empty if the `@url` property is `nil` or an empty
    # String.
    #
    def empty?
      @url.nil? || @url.empty?
    end

    def view
      { 'width' => @width, 'height' => @height, 'url' => @url }
    end

    def self.inflate(record)
      record = {} if record.nil?
      Lynr::Model::Image.new(record['width'], record['height'], record['url'])
    end

    # ## `Image#inflatable?(record)`
    #
    # Check to see if `record` can be converted into an `Image` instance
    # successfully.
    #
    def self.inflatable?(record)
      keys = record.keys
      ['width', 'height', 'url'].count { |attr| keys.include?(attr) } == 3
    end

    # ## `Image::Empty`
    #
    # "Singleton" representation of an empty image.
    #
    Empty = Lynr::Model::Image.new

  end

end; end;
