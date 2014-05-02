require 'rspec/autorun'
require './spec/spec_helper'

require 'libxml'
require 'rexml/document'
require './lib/lynr/converter/data_one'
require './lib/lynr/model/vin'

describe Lynr::Converter::DataOne do

  class DataOneConverter
    include Lynr::Converter::DataOne
  end

  include Lynr::Converter::LibXmlHelper

  let(:converter) { DataOneConverter.new }
  let(:empty_mpg) { Lynr::Model::Mpg.new }
  let(:empty_vehicle) { Lynr::Model::Vehicle.new }
  let(:empty_vin) { Lynr::Model::Vin.new({}) }

  describe ".xml_to_vin" do

    let(:vin) { converter.xml_to_vin(query_response) }

    ['1HGEJ6229XL063838', 'WMWMF7C52ATZ73068', 'WMWZC3C55CWL83987', 'sample-out'].each do |fn|

      context "valid response for #{fn}" do

        let(:path) { './/us_market_data/common_us_data' }
        let(:doc) { LibXML::XML::Document.file("spec/data/#{fn}.xml") }
        let(:query_response) { doc.find("//query_response[@identifier=\"#{fn}\"]").first }

        it "creates a Vin with transmission from XML" do
          expect(vin.transmission).to eq(query_response.find("#{path}//transmission/type").first.content)
        end

        it "creates a Vin with fuel type from XML" do
          expect(vin.fuel).to eq(query_response.find("#{path}//fuel_type").first.content)
        end

        it "creates a Vin with num doors from XML" do
          expect(vin.doors).to eq(query_response.find("#{path}//doors").first.content)
        end

        it "creates a Vin with drivetrain from XML" do
          expect(vin.drivetrain).to eq(query_response.find("#{path}//drive_type").first.content)
        end

        it "creates a Vin without ext_color information" do
          expect(vin.ext_color).to be_nil
        end

        it "creates a Vin without int_color information" do
          expect(vin.int_color).to be_nil
        end

        it "creates a Vin with a number from XML" do
          expect(vin.number).to eq(fn)
        end

        it "creates a Vin with raw data equal to XML" do
          expect(vin.raw).to eq(query_response.to_s)
        end

      end

    end

    context "empty <query_response />" do

      let(:doc) { LibXML::XML::Document.new }
      let(:query_response) {
        node = LibXML::XML::Node.new 'query_response'
        doc.root = node
      }

      it "creates an empty Vin" do
        expect(vin).to eq(empty_vin)
      end

    end

    context "nil query_response" do

      let(:query_response) { nil }

      it "creates an empty Vin" do
        expect(vin).to eq(empty_vin)
      end

    end

  end

  describe ".xml_to_mpg" do

    let(:mpg) { converter.xml_to_mpg(query_response) }

    context "valid XML" do

      let(:path) { './/us_market_data/common_us_data' }
      let(:doc) { LibXML::XML::Document.file('spec/data/1HGEJ6229XL063838.xml') }
      let(:query_response) { doc.find('//query_response[@identifier="1HGEJ6229XL063838"]').first }

      it "creates a Mpg with city from XML" do
        expect(mpg.city).to eq(query_response.find("#{path}//epa_fuel_efficiency//city").first.content)
      end

      it "creates a Mpg with highway from XML" do
        expect(mpg.highway).to eq(query_response.find("#{path}//epa_fuel_efficiency//highway")\
                                  .first.content)
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

      it "creates Mpg with default highway" do
        expect(mpg.highway).to eq(Lynr::Model::Mpg.new.highway)
      end

    end

    context "nil query_response" do

      let(:query_response) { nil }

      it "creates Mpg with default city" do
        expect(mpg.city).to eq(Lynr::Model::Mpg.new.city)
      end

      it "creates Mpg with default highway" do
        expect(mpg.highway).to eq(Lynr::Model::Mpg.new.highway)
      end

    end

  end

  describe ".xml_to_vehicle" do

    let(:vehicle) { converter.xml_to_vehicle(query_response) }
    let(:mpg) { converter.xml_to_mpg(query_response) }
    let(:vin) { converter.xml_to_vin(query_response) }

    context "valid XML" do

      let(:path) { './/us_market_data/common_us_data' }
      let(:doc) { LibXML::XML::Document.file('spec/data/1HGEJ6229XL063838.xml') }
      let(:query_response) { doc.find('//query_response[@identifier="1HGEJ6229XL063838"]').first }

      it "creates a Vehicle with year from XML" do
        expect(vehicle.year).to eq(query_response.find("#{path}/basic_data/year").first.content)
      end

      it "creates a Vehicle with make from XML" do
        expect(vehicle.make).to eq(query_response.find("#{path}/basic_data/make").first.content)
      end

      it "creates a Vehicle with model from XML" do
        model = query_response.find("#{path}/basic_data/model").first.content
        trim = query_response.find("#{path}/basic_data/trim").first.content
        expect(vehicle.model).to eq("#{model} #{trim}")
      end

      it "creates a Vehicle with price from XML" do
        expect(vehicle.price).to eq(query_response.find("#{path}/pricing/msrp").first.content)
      end

      it "creates a Vehicle with Mpg from XML" do
        expect(vehicle.mpg).to eq(mpg)
      end

      it "creates a Vehicle with Vin from XML" do
        expect(vehicle.vin).to eq(vin)
      end

    end

    context "empty <query_response />" do

      let(:doc) { LibXML::XML::Document.new }
      let(:query_response) {
        node = LibXML::XML::Node.new 'query_response'
        doc.root = node
      }

      it "creates an empty Vehicle" do
        expect(vehicle).to eq(empty_vehicle)
      end

    end

    context "nil query_response" do

      let(:query_response) { nil }

      it "creates an empty Vehicle" do
        expect(vehicle).to eq(empty_vehicle)
      end

    end

  end

end
