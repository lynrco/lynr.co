require 'rspec/autorun'
require './spec/spec_helper'

require 'libxml'
require 'rexml/document'
require './lib/lynr/converter/libxml_helper'

describe Lynr::Converter::LibXmlHelper do

  class LibXmlHelperExtended
    extend Lynr::Converter::LibXmlHelper
  end

  let(:doc) { LibXML::XML::Document.new }
  let(:query_response) { LibXML::XML::Node.new 'query_response' }
  let(:decoded_data) { LibXML::XML::Node.new 'decoded_data' }

  describe ".content" do

    it "returns nil for nil context" do
      expect(LibXmlHelperExtended.content(nil, '.')).to be_nil
    end

    it "returns '' for xpath matching single element" do
      root = doc.root = query_response
      expect(LibXmlHelperExtended.content(root, '.')).to eq('')
    end

    it "returns an first value from Array of values for multiple matches" do
      root = doc.root = query_response
      values = ['bar', 'that', 'there']
      nodes = values.each do |v|
        node = LibXML::XML::Node.new 'elem'
        node << v
        root << node
      end
      expect(LibXmlHelperExtended.content(root, './/elem')).to eq(values[0])
    end

  end

  describe ".contents" do

    it "returns [] for nil context" do
      expect(LibXmlHelperExtended.contents(nil, '.')).to eq([])
    end

    it "returns [''] for xpath matching single element" do
      root = doc.root = query_response
      expect(LibXmlHelperExtended.contents(root, '.')).to eq([''])
    end

    it "returns an array of values for multiple matches" do
      root = doc.root = query_response
      values = ['bar', 'that', 'there']
      nodes = values.each do |v|
        node = LibXML::XML::Node.new 'elem'
        node << v
        root << node
      end
      expect(LibXmlHelperExtended.contents(root, './/elem')).to eq(values)
    end

  end

  describe ".value" do

    it "returns nil for nil context" do
      expect(LibXmlHelperExtended.value(nil, '.')).to be_nil
    end

    it "returns '' for xpath matching single empty attribute" do
      root = doc.root = query_response
      query_response['name'] = ''
      expect(LibXmlHelperExtended.value(root, './@name')).to eq('')
    end

    it "returns array of attribute values for multiple matches" do
      root = doc.root = query_response
      values = ['bar', 'that', 'there']
      nodes = values.each do |v|
        node = LibXML::XML::Node.new 'elem'
        node['name'] = v
        root << node
      end
      expect(LibXmlHelperExtended.values(root, './/elem/@name')).to eq(values)
    end

  end

  describe ".values" do

    it "returns [] for nil context" do
      expect(LibXmlHelperExtended.values(nil, '.')).to eq([])
    end

    it "returns [''] for xpath matching single empty attribute" do
      root = doc.root = query_response
      query_response['name'] = ''
      expect(LibXmlHelperExtended.values(root, './@name')).to eq([''])
    end

    it "returns an first value from Array of values for multiple matches" do
      root = doc.root = query_response
      values = ['bar', 'that', 'there']
      nodes = values.each do |v|
        node = LibXML::XML::Node.new 'elem'
        node['name'] = v
        root << node
      end
      expect(LibXmlHelperExtended.value(root, './/elem/@name')).to eq(values[0])
    end

  end

end
