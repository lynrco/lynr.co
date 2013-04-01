require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/vehicle'

describe Lynr::Model::Vehicle do

  before(:all) do
    @make = "Honda"
    @model = "Civic EX"
    @year = "2009"
  end

  let(:vehicle) { Lynr::Model::Vehicle.new({ 'year' => @year, 'make' => @make, 'model' => @model }) }

  describe "#initialize" do

    it "has a make property" do
      expect(vehicle.make).to eq(@make)
    end

    it "has a model property" do
      expect(vehicle.model).to eq(@model)
    end

    it "has a year property" do
      expect(vehicle.year).to eq(@year)
    end

  end

end
