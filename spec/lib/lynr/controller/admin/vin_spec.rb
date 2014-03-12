require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/controller/admin/vin'

describe Lynr::Controller::AdminVin do

  let(:controller) { Lynr::Controller::AdminVin.new }
  let(:query) { controller.dataone_xml_query('1HGEJ6229XL063838') }
  let(:doc) { LibXML::XML::Document.string(query) }

  describe "#dataone_xml_query" do

    it "contains a <query_request> element" do
      expect(doc.find('.//query_request').length).to be > 0
    end

    context "<query_request>" do

      let(:query_request) { doc.find('.//query_request').first }

      it "has identifier equal to vin" do
        expect(controller.value(query_request, './@identifier')).to eq('1HGEJ6229XL063838')
      end

      it "has a <vin /> with content equal to vin number requested" do
        expect(controller.content(query_request, './vin')).to eq('1HGEJ6229XL063838')
      end

    end

    it "contains a <decoder_settings> element" do
      expect(doc.find('.//decoder_settings').length).to be > 0
    end

    context "<decoder_settings>" do

      let(:decoder_settings) { doc.find('.//decoder_settings').first }

      it "has a <version /> of 7.0.1" do
        expect(controller.content(decoder_settings, './version')).to eq('7.0.1')
      end

      it "has <style_data_packs /> information" do
        expect(decoder_settings.find('./style_data_packs').length).to be > 0
      end

      it "has <common_data_packs /> information" do
        expect(decoder_settings.find('./common_data_packs').length).to be > 0
      end

      it "has <styles> on" do
        expect(controller.content(decoder_settings, './styles')).to eq('on')
      end

      it "has <common_data> on" do
        expect(controller.content(decoder_settings, './common_data')).to eq('on')
      end

      context "<style_data_packs>" do

        let(:style_data_packs) { decoder_settings.find('./style_data_packs').first }

        it "has <basic_data> on" do
          expect(controller.content(style_data_packs, './basic_data')).to eq('on')
        end

        it "has <specifications> on" do
          expect(controller.content(style_data_packs, './specifications')).to eq('on')
        end

        it "has <engines> on" do
          expect(controller.content(style_data_packs, './engines')).to eq('on')
        end

        it "has <transmissions> on" do
          expect(controller.content(style_data_packs, './transmissions')).to eq('on')
        end

        it "has <installed_equipment> off" do
          expect(controller.content(style_data_packs, './installed_equipment')).to eq('off')
        end

        it "has <safety_equipment> off" do
          expect(controller.content(style_data_packs, './safety_equipment')).to eq('off')
        end

        it "has <optional_equipment> off" do
          expect(controller.content(style_data_packs, './optional_equipment')).to eq('off')
        end

        it "has <generic_optional_equipment> off" do
          expect(controller.content(style_data_packs, './generic_optional_equipment')).to eq('off')
        end

        it "has <colors> on" do
          expect(controller.content(style_data_packs, './colors')).to eq('on')
        end

        it "has <fuel_efficiency> on" do
          expect(controller.content(style_data_packs, './fuel_efficiency')).to eq('on')
        end

        it "has <pricing> on" do
          expect(controller.content(style_data_packs, './pricing')).to eq('on')
        end

      end

    end

  end

  describe "#fetch" do

    DecodeEnabled = Lynr.features.fetch('dataone_decode', false)

    let(:config) { Lynr.config('app').vin.dataone }
    let(:dataone_response) { File.read("spec/data/1HGEJ6229XL063838.xml") }

    before(:each) do
      subject.stub(:fetch_dataone) do |vin|
        File.read("spec/data/1HGEJ6229XL063838.xml").gsub('1HGEJ6229XL063838', vin)
      end
    end

    after(:each) do
      MongoHelpers.empty! if MongoHelpers.dao.active?
    end

    context "with active DB and primed cache", :if => (MongoHelpers.connected?) do

      before(:each) do
        Lynr.cache.write('1HG', dataone_response.gsub('1HGEJ6229XL063838', '1HG'))
      end

      it "can find '1HG' in cache" do
        expect(Lynr.cache.include?('1HG')).to be_true
      end

      it "fetches dataone_response for 1HG" do
        expect(subject.fetch('1HG')).to be_instance_of(LibXML::XML::Node)
      end

    end

    context "with active DB and decode", :if => (MongoHelpers.connected?) do

      before(:each) do
        Lynr.stub(:features) do |type, defaults|
          Lynr::Config.new(nil, nil, { dataone_decode: true })
        end
      end

      it "can't find '1HG' in cache" do
        expect(Lynr.cache.include?('1HG')).to be_false
      end

      it "fetches dataone_response for 1HG" do
        expect(subject.fetch('1HG')).to be_instance_of(LibXML::XML::Node)
      end

      it "stores response in cache" do
        node = subject.fetch('1HG')
        expect(Lynr.cache.include?('1HG')).to be_true
      end

    end

    context "with active DB and no decode", :if => (MongoHelpers.connected?) do

      before(:each) do
        Lynr.stub(:features) do |type, defaults|
          Lynr::Config.new(nil, nil, { dataone_decode: false })
        end
      end

      it "can't find '1HG' in cache" do
        expect(Lynr.cache.include?('1HG')).to be_false
      end

      it "gets nil if not decoding" do
        expect(subject.fetch('1HG')).to be_nil
      end

    end

  end

end
