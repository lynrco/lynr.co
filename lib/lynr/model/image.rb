require './lib/lynr/model/base'

module Lynr; module Model;

  class Image

    include Base

    Empty = Image.new

    attr_reader :width, :height

    def initialize(width=nil, height=nil, url=nil)
      @width = width.to_i
      @height = height.to_i
      @url = url
    end

    def url
      if self.empty?
        "/img/blank.gif"
      else
        @url
      end
    end

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

  end

end; end;
