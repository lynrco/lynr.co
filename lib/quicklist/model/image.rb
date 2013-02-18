module Quicklist; module Model;

  class Image

    attr_reader :id
    attr_reader :width, :height, :url

    def initialize(width, height, url, id=nil)
      @id = id
      @width = width.to_i
      @height = height.to_i
      @url = url
    end

    def view
      { width: @width, height: @height, url: @url }
    end

    def ==(obj)
      obj.respond_to?(:width) && obj.respond_to?(:height) && obj.respond_to?(:url) &&
          obj.width == @width && obj.height == @height && obj.url == @url
    end

  end

end; end;
