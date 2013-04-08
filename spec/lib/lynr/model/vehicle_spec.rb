require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/mpg'
require './lib/lynr/model/vehicle'

describe Lynr::Model::Vehicle do

  before(:all) do
    @make = "Honda"
    @model = "Civic EX"
    @year = "2009"
  end

  let(:vehicle) { Lynr::Model::Vehicle.new({ 'year' => @year, 'make' => @make, 'model' => @model }) }
  let(:empty_vehicle) { Lynr::Model::Vehicle.new }

  describe "#initialize" do

    it "gives an empty object when given no parameters" do
      expect(empty_vehicle.make).to eq("")
      expect(empty_vehicle.model).to eq("")
      expect(empty_vehicle.year).to eq("")
      expect(empty_vehicle.price).to eq(0.0)
      expect(empty_vehicle.condition).to eq(0)
      expect(empty_vehicle.mpg).to be_nil
      expect(empty_vehicle.vin).to be_nil
      expect(empty_vehicle.images).to eq([])
      expect(empty_vehicle.dealership).to be_nil
    end

  end

  describe "#==" do

    it "is true if properties are the same" do
      v = Lynr::Model::Vehicle.new({ 'year' => @year, 'make' => @make, 'model' => @model })
      expect(v).to eq(vehicle)
    end

    it "is false if properties are not the same" do
      v = Lynr::Model::Vehicle.new({ 'year' => "2010", 'make' => @make, 'model' => @model })
      expect(v).to_not eq(vehicle)
    end

    it "is false if complex properties are not the same" do
      v = Lynr::Model::Vehicle.new({
        'year' => "2010",
        'make' => @make,
        'model' => @model,
        'mpg' => Lynr::Model::Mpg.new('city' => 22.2)
      })
      v2 = vehicle.set({ 'mpg' => Lynr::Model::Mpg.new('city' => 22.1) })
      expect(v2).to_not eq(v)
      expect(v).to_not eq(v2)
    end

    it "is true if complex properties are the same" do
      v = Lynr::Model::Vehicle.new({
        'year' => @year,
        'make' => @make,
        'model' => @model,
        'mpg' => Lynr::Model::Mpg.new('city' => 22.1)
      })
      v2 = vehicle.set({ 'mpg' => Lynr::Model::Mpg.new('city' => 22.1) })
      expect(v2).to eq(v)
      expect(v).to eq(v2)
    end

    it "is true if compared to a Hash representing the view" do
      expect(vehicle).to eq(vehicle.view)
    end

  end

  describe ".inflate" do

    it "provides empty vehicle for nil" do
      expect(Lynr::Model::Vehicle.inflate(nil)).to eq(empty_vehicle)
    end

  end

end
