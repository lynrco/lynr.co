require 'rspec/autorun'
require './spec/spec_helper'

require 'libxml'
require 'rexml/document'
require './lib/lynr/converter/libxml_helper'

describe Lynr::Converter::LibXmlHelper do

  let(:doc) { LibXML::XML::Document.new }
  let(:query_response) { LibXML::XML::Node.new 'query_response' }
  let(:decoded_data) { LibXML::XML::Node.new 'decoded_data' }

  describe ".contents" do

    it "returns [] for nil context" do
      expect(Lynr::Converter::LibXmlHelper.contents(nil, '.')).to eq([])
    end

    it "returns [''] for xpath matching single element" do
      root = doc.root = query_response
      expect(Lynr::Converter::LibXmlHelper.contents(root, '.')).to eq([''])
    end

    it "returns an array of values for multiple matches" do
      root = doc.root = query_response
      values = ['bar', 'that', 'there']
      nodes = values.each do |v|
        node = LibXML::XML::Node.new 'elem'
        node << v
        root << node
      end
      expect(Lynr::Converter::LibXmlHelper.contents(root, './/elem')).to eq(values)
    end

  end

  describe ".values" do

    it "returns [] for nil context" do
      expect(Lynr::Converter::LibXmlHelper.values(nil, '.')).to eq([])
    end

    it "returns [''] for xpath matching single empty attribute" do
      root = doc.root = query_response
      query_response['name'] = ''
      expect(Lynr::Converter::LibXmlHelper.values(root, './@name')).to eq([''])
    end

    it "returns array of attribute values for multiple matches" do
      root = doc.root = query_response
      values = ['bar', 'that', 'there']
      nodes = values.each do |v|
        node = LibXML::XML::Node.new 'elem'
        node['name'] = v
        root << node
      end
      expect(Lynr::Converter::LibXmlHelper.values(root, './/elem/@name')).to eq(values)
    end

  end

end
