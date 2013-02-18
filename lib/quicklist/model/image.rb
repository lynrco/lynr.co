module Quicklist; module Model;

  class Image

    attr_reader :id
    attr_reader :width, :height, :url

    def initialize(width, height, url, id=nil)
      @id = id
      @width = width
      @height = height
      @url = url
    end

    def view
      { width: @width, height: @height, url: @url }
    end

  end

end; end;
