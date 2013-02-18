require './lib/quicklist/model/base'

module Quicklist; module Model;

  class Image
    include Quicklist::Model::Base

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

  end

end; end;
