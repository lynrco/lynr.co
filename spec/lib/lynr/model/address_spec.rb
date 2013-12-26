require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/address'

describe Lynr::Model::Address do

  let(:address_props) {
    {
      'line_one' => "Addr L1",
      'line_two' => "Addr L2",
      'city' => "New York",
      'state' => "NY",
      'zip' => "10002"
    }
  }
  let(:empty_address) {
    Lynr::Model::Address.new({
      'line_one' => nil,
      'line_two' => nil,
      'city' => nil,
      'state' => nil,
      'zip' => nil
    })
  }

  let(:address) {
    Lynr::Model::Address.new({
      'line_one' => "Addr L1",
      'line_two' => "Addr L2",
      'city' => "New York",
      'state' => "NY",
      'zip' => "10002"
    })
  }

  let(:coded) {
    Lynr::Model::Address.new({
      'line_one' => "Addr L1",
      'line_two' => "Addr L2",
      'city' => "New York",
      'state' => "NY",
      'zip' => "10002",
      'geo' => {
        'type' => 'Point',
        'coordinates' => [-73.9896868, 40.718728]
      }
    })
  }

  describe "#initialize" do

    it "has line_one" do
      expect(address.line_one).to eq('Addr L1')
    end

    it "has line_two" do
      expect(address.line_two).to eq('Addr L2')
    end

    it "has city" do
      expect(address.city).to eq('New York')
    end

    it "has state" do
      expect(address.state).to eq('NY')
    end

    it "has zip" do
      expect(address.zip).to eq('10002')
    end

    it "has geo" do
      expect(address.geo).to be_nil
    end

    context "geocoded" do

      it "has Point as geo" do
        expect(coded.geo).to be_instance_of(GeoRuby::SimpleFeatures::Point)
      end

    end

  end

  describe "#view" do

    let(:view) { address.view }

    it "has keys for line_one, line_two, city, state, zip" do
      expect(view.keys).to include('line_one', 'line_two', 'city', 'state', 'zip')
    end

    it "has values for line_one, line_two, city, state, zip" do
      expect(view['line_one']).to eq('Addr L1')
      expect(view['line_two']).to eq('Addr L2')
      expect(view['city']).to eq('New York')
      expect(view['state']).to eq('NY')
      expect(view['zip']).to eq('10002')
      expect(view['geo']).to be_nil
    end

    context "geocoded" do

      let(:view) { coded.view }

      it "has geo data" do
        expect(view['geo']).to_not be_nil
      end

      it "has GeoJSON representation of a point" do
        geo = view['geo']
        expect(geo['type']).to eq('Point')
        expect(geo['coordinates']).to eq([-73.9896868, 40.718728])
      end

    end

  end

  describe "#==" do

    let(:a2) {
      Lynr::Model::Address.new({
        'line_one' => "Addr L1",
        'line_two' => "Addr L2",
        'city' => "New York",
        'state' => "NY",
        'zip' => "10002"
      })
    }

    it "is true if properties are the same" do
      expect(address == a2).to be_true
      expect(address.equal?(a2)).to be_false
    end

    it "is true if compared to a Hash representing the view" do
      expect(address == address.view).to be_true
    end

    context "geocoded" do

      let(:coded2) {
        Lynr::Model::Address.new({
          'line_one' => "Addr L1",
          'line_two' => "Addr L2",
          'city' => "New York",
          'state' => "NY",
          'zip' => "10002",
          'geo' => {
            'type' => 'Point',
            'coordinates' => [-73.9896868, 40.718728]
          }
        })
      }

      it "is true if properties are the same and geo data is included" do
        expect(coded == coded2).to be_true
        expect(coded.equal?(coded2)).to be_false
      end

    end

  end

  describe ".inflate" do

    it "creates equivalent instances from properties" do
      expect(Lynr::Model::Address.inflate(address_props)).to eq(address)
    end

    it "creates equivalent instances from properties with geodata" do
      props = address_props.dup
      props['geo'] = { 'type' => 'Point', 'coordinates' => [-73.9896868, 40.718728] }
      expect(Lynr::Model::Address.inflate(props)).to eq(coded)
    end

    it "creates empty instance from nil" do
      expect(Lynr::Model::Address.inflate(nil)).to eq(empty_address)
    end

  end

end
