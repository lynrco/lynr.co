require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/image'
require './lib/lynr/model/mpg'
require './lib/lynr/model/vehicle'
require './lib/lynr/model/vin'

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

    it "is false if types are different" do
      mpg = Lynr::Model::Mpg.new('city' => 22.1)
      expect(vehicle).to_not eq(mpg)
    end

    it "is false if types are different but properties are the same" do
      expect(vehicle).to_not eq(vehicle.view)
    end

  end

  describe "#image" do

    let(:image1) { Lynr::Model::Image.new("300", "150", "//lynr.co/assets/dummy1.gif") }
    let(:image2) { Lynr::Model::Image.new("300", "150", "//lynr.co/assets/dummy2.gif") }
    let(:image3) { Lynr::Model::Image.new("300", "150", "//lynr.co/assets/dummy3.gif") }

    it "is the first non-empty image when there are images" do
      v = vehicle.set({ 'images' => [Lynr::Model::Image::Empty, image2] })
      expect(v.image).to eq(image2)
    end

    it "is the first image when no images are empty" do
      v = vehicle.set({ 'images' => [image1, image2] })
      expect(v.image).to eq(image1)
    end

    it "is Image::Empty when there are no images" do
      expect(vehicle.image).to eq(Lynr::Model::Image::Empty)
    end

    it "is Image::Empty when all images are empty" do
      v = vehicle.set({ 'images' => [Lynr::Model::Image::Empty, Lynr::Model::Image::Empty] })
      expect(vehicle.image).to eq(Lynr::Model::Image::Empty)
    end

  end

  # TODO: Need specs for images method
  describe "#images" do

  end

  describe "#images?" do

    it "is true if at least one image exists" do
      dummy_images = [Lynr::Model::Image.new("300", "150", "//lynr.co/assets/dummy.gif")]
      dummy_vehicle = vehicle.set({ 'images' => dummy_images })
      expect(dummy_vehicle.images?).to be_true
    end

    it "is false if there are no images" do
      expect(vehicle.images?).to be_false
    end

  end

  describe "#name" do

    it "returns {year make model} when they exist" do
      expect(vehicle.name).to eq("2009 Honda Civic EX")
    end

    it "returns {year make} when model is empty" do
      v = Lynr::Model::Vehicle.new({ "year" => "2010", "make" => "Honda" })
      expect(v.name).to eq("2010 Honda")
    end

    it "returns {year} when make and model are empty" do
      v = Lynr::Model::Vehicle.new({ "year" => "2010" })
      expect(v.name).to eq("2010")
    end

    it "returns N/A when year make and model are empty" do
      expect(empty_vehicle.name).to eq("N/A")
    end

    it "returns {make model} when year is empty" do
      v = Lynr::Model::Vehicle.new({ "make" => "Honda", "model" => "Civic EX" })
      expect(v.name).to eq("Honda Civic EX")
    end

  end

  describe "#set" do

    it "returns a new Vehicle instance" do
      expect(vehicle.set({})).to_not equal(vehicle)
    end

    it "returns an equivalent instance if no fields are passed" do
      expect(vehicle.set({})).to eq(vehicle)
    end

    it "updates a simple field if passed" do
      expect(vehicle.set({ 'year' => '2015' }).year).to eq('2015')
    end

    it "updates a complex field if passed" do
      dummy_images = [Lynr::Model::Image.new("300", "150", "//lynr.co/assets/dummy.gif")]
      dummy_vehicle = vehicle.set({ 'images' => dummy_images })
      expect(dummy_vehicle.images).to eq(dummy_images)
      expect(dummy_vehicle.images).to_not eq(vehicle.images)
    end

  end

  describe ".inflate" do

    let(:img) { Lynr::Model::Image.new("300", "150", "//lynr.co/assets/image.gif") }
    let(:image) { Lynr::Model::SizedImage.new({ 'original' => img }) }
    let(:mpg) { Lynr::Model::Mpg.new({ 'city' => 28.8, 'highway' => 33.2 }) }
    let(:vin) { Lynr::Model::Vin.new("Manual", "28 L", "2", "AWD", "Silver", "Charcoal") }
    let(:vehicle_data) {
      {
        'year'       => '2010',
        'make'       => 'Mitsubishi',
        'model'      => 'Gallant',
        'price'      => 4999.99,
        'condition'  => 3,
        'mpg'        => mpg,
        'vin'        => vin,
        'images'     => [image]
      }
    }

    it "provides empty vehicle for nil" do
      expect(Lynr::Model::Vehicle.inflate(nil)).to eq(empty_vehicle)
    end

    it "gives the same vehicle back" do
      v = Lynr::Model::Vehicle.new(vehicle_data)
      expect(Lynr::Model::Vehicle.inflate(v.view)).to eq(v)
    end

  end

end
