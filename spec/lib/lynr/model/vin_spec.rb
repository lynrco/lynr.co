require 'rspec/autorun'
require './spec/spec_helper'

require 'libxml'
require './lib/lynr/model/vin'

describe Lynr::Model::Vin do

  let(:vin) {
    Lynr::Model::Vin.new(
      'transmission' => "Manual",
      'fuel' => "28 L",
      'doors' => "2",
      'drivetrain' => "AWD",
      'ext_color' => "Silver",
      'int_color' => "Charcoal"
    )
  }
  let(:empty_vin) { Lynr::Model::Vin.new({}) }

  describe "#method_missing" do

    it "raises error when property not in ATTRS" do
      expect { vin.unknown_property }.to raise_error
    end

    it "raises error when known property but arguments" do
      expect { vin.make('Honda') }.to raise_error
    end

    it "raises error when known propery but block given" do
      expect { vin.make { 'Honda' } }.to raise_error
    end

  end

  describe "#set" do

    it "creates a new Vin instance" do
      expect(vin.set({})).to_not equal(vin)
    end

    it "creates an equivalent Vin instance" do
      expect(vin.set({})).to eq(vin)
    end

    it "updates a property" do
      new_vin = vin.set({ 'transmission' => 'Automatic' })
      expect(new_vin.transmission).to eq('Automatic')
    end

    it "leaves other properties unchanged" do
      new_vin = vin.set({ 'transmission' => 'Automatic' })
      expect(new_vin.fuel).to eq(vin.fuel)
      expect(new_vin.doors).to eq(vin.doors)
      expect(new_vin.drivetrain).to eq(vin.drivetrain)
      expect(new_vin.ext_color).to eq(vin.ext_color)
      expect(new_vin.int_color).to eq(vin.int_color)
    end

  end

  describe "#view" do

    it "has a :transmission property" do
      expect(vin.view.keys).to include('transmission')
    end

    it "has a :fuel property" do
      expect(vin.view.keys).to include('fuel')
    end

    it "has a :doors property" do
      expect(vin.view.keys).to include('doors')
    end

    it "has a :drivetrain property" do
      expect(vin.view.keys).to include('drivetrain')
    end

    it "has a :ext_color property" do
      expect(vin.view.keys).to include('ext_color')
    end

    it "has a :int_color property" do
      expect(vin.view.keys).to include('int_color')
    end

    it "has a :number property" do
      expect(vin.view.keys).to include('number')
    end

  end

  describe "#==" do

    it "is true if properties are the same" do
      vin2 = Lynr::Model::Vin.new(
        'transmission' => "Manual",
        'fuel' => "28 L",
        'doors' => "2",
        'drivetrain' => "AWD",
        'ext_color' => "Silver",
        'int_color' => "Charcoal"
      )
      expect(vin == vin2).to be_true
      expect(vin.equal?(vin2)).to be_false
    end

    it "is true if compared to a Hash representing the view" do
      expect(vin == vin.view).to be_true
    end

  end

  describe ".inflate" do

    it "creates equivalent Vin instances from properties" do
      vin_props = {
        'transmission' => "Manual",
        'fuel' => "28 L",
        'doors' => "2",
        'drivetrain' => "AWD",
        'ext_color' => "Silver",
        'int_color' => "Charcoal"
      }
      expect(Lynr::Model::Vin.inflate(vin_props)).to eq(vin)
    end

    it "provides an empty Vin for nil" do
      expect(Lynr::Model::Vin.inflate(nil)).to eq(empty_vin)
    end

  end

end
