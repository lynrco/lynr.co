require './lib/quicklist/model/base'

module Quicklist; module Model;

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
      Quicklist::Model::Mpg.new(record)
    end

  end

end; end;
