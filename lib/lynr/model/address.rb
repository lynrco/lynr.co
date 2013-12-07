require './lib/lynr/model/base'

module Lynr; module Model;

  class Address

    include Base

    attr_reader :line_one, :line_two, :city, :state, :zip

    alias postcode :zip

    def initialize(data={})
      @line_one = data.fetch('line_one', default=nil)
      @line_two = data.fetch('line_two', default=nil)
      @city = data.fetch('city', default=nil)
      @state = data.fetch('state', default=nil)
      @zip = data.fetch('zip', default=nil)
    end

    def view
      {
        'line_one' => @line_one,
        'line_two' => @line_two,
        'city' => @city,
        'state' => @state,
        'zip' => @zip
      }
    end

    def self.inflate(record)
      record = {} if record.nil?
      Lynr::Model::Address.new(record)
    end

  end

end; end;
