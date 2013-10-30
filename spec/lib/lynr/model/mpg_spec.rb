require 'rspec/autorun'
require './spec/spec_helper'

require 'libxml'
require 'rexml/document'
require './lib/lynr/model/mpg'

describe Lynr::Model::Mpg do

  let(:mpg_props) { { 'city' => 28.8, 'highway' => 33.2 } }
  let(:mpg) { Lynr::Model::Mpg.new(mpg_props) }
  let(:empty_mpg) { Lynr::Model::Mpg.new }

  describe "#initialize" do

    it "provides an empty Mpg instance for no args" do
      expect(empty_mpg.city).to eq(0.0)
      expect(empty_mpg.highway).to eq(0.0)
    end

  end

  describe ".inflate" do

    it "provides an empty Mpg instance for nil" do
      expect(Lynr::Model::Mpg.inflate(nil)).to eq(empty_mpg)
    end

    it "creates an equivalent object from a Hash" do
      expect(Lynr::Model::Mpg.inflate({ 'city' => 28.8, 'highway' => 33.2 })).to eq(mpg)
    end

  end

  describe ".inflate_xml" do

    let(:mpg) { Lynr::Model::Mpg.inflate_xml(query_response) }

    context "valid XML" do

      let(:path) { './/us_market_data/common_us_data' }
      let(:doc) { LibXML::XML::Document.file('spec/data/1HGEJ6229XL063838.xml') }
      let(:query_response) { doc.find('//query_response[@identifier="1HGEJ6229XL063838"]').first }

      it "creates a Mpg with city from XML" do
        expect(mpg.city).to eq(query_response.find("#{path}//epa_fuel_efficiency//city").first.content)
      end

      it "creates a Mpg with highway from XML" do
        expect(mpg.highway).to eq(query_response.find("#{path}//epa_fuel_efficiency//highway").first.content)
      end

    end

    context "empty <query_response />" do

      let(:doc) { LibXML::XML::Document.new }
      let(:query_response) {
        node = LibXML::XML::Node.new 'query_response'
        doc.root = node
      }

      it "creates Mpg with default city" do
        expect(mpg.city).to eq(Lynr::Model::Mpg.new.city)
      end

    end

  end

end
