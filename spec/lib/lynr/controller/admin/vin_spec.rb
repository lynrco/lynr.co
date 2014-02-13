require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/controller/admin/vin'

describe Lynr::Controller::AdminVin do

  let(:controller) { Lynr::Controller::AdminVin.new }

  describe "#dataone_xml_query" do

    it "contains a <query_request> element" do
      query_request = controller.dataone_xml_query('1HGEJ6229XL063838')
      doc = LibXML::XML::Document.string(query_request)
      els = doc.find('.//query_request')
      expect(els.length).to be > 0
    end

  end

end
