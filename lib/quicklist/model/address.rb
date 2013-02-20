require './lib/quicklist/model/base'

module Quicklist; module Model;

  class Address

    include Base

    attr_reader :line_one, :line_two, :city, :state, :zip

    def initialize(line_one, line_two, city, state, zip)
      @line_one = line_one
      @line_two = line_two
      @city = city
      @state = state
      @zip = zip
    end

    def view
      { line_one: @line_one, line_two: @line_two, city: @city, state: @state, zip: @zip }
    end

  end

end; end;
