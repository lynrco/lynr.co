require 'rspec/autorun'
require './spec/spec_helper'

require 'libxml'
require 'rexml/document'
require './lib/lynr/model/vin'

describe Lynr::Model::Vin do

  let(:vin) { Lynr::Model::Vin.new("Manual", "28 L", "2", "AWD", "Silver", "Charcoal") }
  let(:empty_vin) { Lynr::Model::Vin.new(nil, nil, nil, nil, nil, nil) }

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
      vin2 = Lynr::Model::Vin.new("Manual", "28 L", "2", "AWD", "Silver", "Charcoal")
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

  describe ".inflate_xml" do

    context "valid XML" do

      let(:doc) { LibXML::XML::Document.file('spec/data/1HGEJ6229XL063838.xml') }
      let(:query_response) { doc.find('//query_response[@identifier="1HGEJ6229XL063838"]').first }
      let(:vin) { Lynr::Model::Vin.inflate_xml(query_response) }

      it "creates a Vin with transmission from XML" do
        expect(vin.transmission).to eq(query_response.find('.//us_market_data/common_us_data//transmission/@name').first.value)
      end

      it "creates a Vin with fuel type from XML" do
        expect(vin.fuel).to eq(query_response.find('.//us_market_data/common_us_data//fuel_type').first.content)
      end

      it "creates a Vin with num doors from XML" do
        expect(vin.doors).to eq(query_response.find('.//us_market_data/common_us_data//doors').first.content)
      end

      it "creates a Vin with drivetrain from XML" do
        expect(vin.drivetrain).to eq(query_response.find('.//us_market_data/common_us_data//drive_type').first.content)
      end

      it "creates a Vin with ext_colors from XML" do
        ext_colors = query_response.find('.//us_market_data/common_us_data//exterior_colors//generic_color_name').map { |el| el.content }
        expect(vin.ext_color).to eq(ext_colors.join(', '))
      end

      it "creates a Vin with int_colors from XML" do
        expect(vin.int_color).to eq(query_response.find('.//us_market_data/common_us_data//interior_colors//generic_color_name').first.content)
      end

      it "creates a Vin with a number from XML" do
        expect(vin.number).to eq('1HGEJ6229XL063838')
      end

      it "creates a Vin with raw data equal to XML" do
        expect(vin.raw).to eq(query_response.to_s)
      end

    end

  end

end
