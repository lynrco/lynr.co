require 'rspec/autorun'
require './lib/quicklist/model/vin'

describe Lynr::Model::Vin do

  let(:vin) { Lynr::Model::Vin.new("Manual", "28 L", "2", "AWD", "Silver", "Charcoal") }

  describe "#view" do

    it "has a :transmission property" do
      expect(vin.view.keys).to include(:transmission)
    end

    it "has a :fuel property" do
      expect(vin.view.keys).to include(:fuel)
    end

    it "has a :doors property" do
      expect(vin.view.keys).to include(:doors)
    end

    it "has a :drivetrain property" do
      expect(vin.view.keys).to include(:drivetrain)
    end

    it "has a :ext_color property" do
      expect(vin.view.keys).to include(:ext_color)
    end

    it "has a :int_color property" do
      expect(vin.view.keys).to include(:int_color)
    end

    it "has a :number property" do
      expect(vin.view.keys).to include(:number)
    end

  end

  describe "#==" do

    it "is true if properties are the same" do
      vin2 = Lynr::Model::Vin.new("Manual", "28 L", "2", "AWD", "Silver", "Charcoal")
      expect(vin == vin2).to be_true
      expect(vin.equal?(vin2)).to be_false
    end

    it "is true if compared to a Hash representing the view" do
      expect(vin == vin.view).to be_true
    end

  end

end
