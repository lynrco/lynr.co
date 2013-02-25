require './lib/lynr/model/base'

module Lynr; module Model;

  class Mpg

    include Base

    attr_reader :city, :highway

    def initialize(data)
      @city = data[:city] || 0.0
      @highway = data[:highway] || 0.0
    end

    def view
      { city: @city, highway: @highway }
    end

    def self.inflate(record)
      Lynr::Model::Mpg.new(record)
    end

  end

end; end;
