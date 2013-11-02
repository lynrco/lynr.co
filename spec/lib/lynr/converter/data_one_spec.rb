require 'rspec/autorun'
require './spec/spec_helper'

require 'libxml'
require 'rexml/document'
require './lib/lynr/converter/data_one'
require './lib/lynr/model/vin'

describe Lynr::Converter::DataOne do

  let(:converter) { Lynr::Converter::DataOne.new }
  let(:empty_vin) { Lynr::Model::Vin.new(nil, nil, nil, nil, nil, nil) }

  describe ".xml_to_vin" do

    let(:vin) { Lynr::Converter::DataOne.xml_to_vin(query_response) }

    context "valid XML" do

      let(:path) { './/us_market_data/common_us_data' }
      let(:doc) { LibXML::XML::Document.file('spec/data/1HGEJ6229XL063838.xml') }
      let(:query_response) { doc.find('//query_response[@identifier="1HGEJ6229XL063838"]').first }

      it "creates a Vin with transmission from XML" do
        expect(vin.transmission).to eq(query_response.find("#{path}//transmission/@name").first.value)
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

      it "creates a Vin with ext_colors from XML" do
        ext_colors = query_response.find("#{path}//exterior_colors//generic_color_name").map { |el| el.content }
        expect(vin.ext_color).to eq(ext_colors.join(', '))
      end

      it "creates a Vin with int_colors from XML" do
        expect(vin.int_color).to eq(query_response.find("#{path}//interior_colors//generic_color_name").first.content)
      end

      it "creates a Vin with a number from XML" do
        expect(vin.number).to eq('1HGEJ6229XL063838')
      end

      it "creates a Vin with raw data equal to XML" do
        expect(vin.raw).to eq(query_response.to_s)
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

    let(:mpg) { Lynr::Converter::DataOne.xml_to_mpg(query_response) }

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

end
