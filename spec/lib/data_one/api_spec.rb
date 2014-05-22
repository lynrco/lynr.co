require 'rspec/autorun'
require './spec/spec_helper'

require './lib/data_one'

describe DataOne::Api do

  subject(:api) { DataOne::Api.new }
  let(:query) { subject.dataone_xml_query('1HGEJ6229XL063838') }
  let(:doc) { LibXML::XML::Document.string(query) }

  describe '#dataone_xml_query' do

    it 'contains a <query_request> element' do
      expect(doc.find('.//query_request').length).to be > 0
    end

    context '<query_request>' do

      let(:query_request) { doc.find('.//query_request').first }

      it 'has identifier equal to vin' do
        expect(api.value(query_request, './@identifier')).to eq('1HGEJ6229XL063838')
      end

      it 'has a <vin /> with content equal to vin number requested' do
        expect(api.content(query_request, './vin')).to eq('1HGEJ6229XL063838')
      end

    end

    it 'contains a <decoder_settings> element' do
      expect(doc.find('.//decoder_settings').length).to be > 0
    end

    context '<decoder_settings>' do

      let(:decoder_settings) { doc.find('.//decoder_settings').first }

      it 'has a <version /> of 7.0.1' do
        expect(api.content(decoder_settings, './version')).to eq('7.0.1')
      end

      it 'has <style_data_packs /> information' do
        expect(decoder_settings.find('./style_data_packs').length).to be > 0
      end

      it 'has <common_data_packs /> information' do
        expect(decoder_settings.find('./common_data_packs').length).to be > 0
      end

      it 'has <styles> on' do
        expect(api.content(decoder_settings, './styles')).to eq('on')
      end

      it 'has <common_data> on' do
        expect(api.content(decoder_settings, './common_data')).to eq('on')
      end

      context '<style_data_packs>' do

        let(:style_data_packs) { decoder_settings.find('./style_data_packs').first }

        it 'has <basic_data> on' do
          expect(api.content(style_data_packs, './basic_data')).to eq('on')
        end

        it 'has <specifications> on' do
          expect(api.content(style_data_packs, './specifications')).to eq('on')
        end

        it 'has <engines> on' do
          expect(api.content(style_data_packs, './engines')).to eq('on')
        end

        it 'has <transmissions> on' do
          expect(api.content(style_data_packs, './transmissions')).to eq('on')
        end

        it 'has <installed_equipment> off' do
          expect(api.content(style_data_packs, './installed_equipment')).to eq('off')
        end

        it 'has <safety_equipment> off' do
          expect(api.content(style_data_packs, './safety_equipment')).to eq('off')
        end

        it 'has <optional_equipment> off' do
          expect(api.content(style_data_packs, './optional_equipment')).to eq('off')
        end

        it 'has <generic_optional_equipment> off' do
          expect(api.content(style_data_packs, './generic_optional_equipment')).to eq('off')
        end

        it 'has <colors> on' do
          expect(api.content(style_data_packs, './colors')).to eq('on')
        end

        it 'has <fuel_efficiency> on' do
          expect(api.content(style_data_packs, './fuel_efficiency')).to eq('on')
        end

        it 'has <pricing> on' do
          expect(api.content(style_data_packs, './pricing')).to eq('on')
        end

      end

    end

  end

  describe '#fetch' do

    let(:config) { Lynr.config('app').vin.dataone }
    let(:dataone_response) { File.read('spec/data/1HGEJ6229XL063838.xml') }

    before(:each) do
      api.stub(:fetch_dataone) do |vin|
        File.read('spec/data/1HGEJ6229XL063838.xml').gsub('1HGEJ6229XL063838', vin)
      end
    end

    context 'with active DB and primed cache', :if => (MongoHelpers.connected?) do

      before(:each) do
        Lynr.cache.write('1HG', dataone_response.gsub('1HGEJ6229XL063838', '1HG'))
      end

      it "can find '1HG' in cache" do
        expect(Lynr.cache.include?('1HG')).to be_true
      end

      it 'fetches dataone_response for 1HG' do
        expect(api.fetch('1HG')).to be_instance_of(LibXML::XML::Node)
      end

    end

    context 'with active DB and decode', :if => (MongoHelpers.connected?) do

      before(:each) do
        Lynr.stub(:features) do |type, defaults|
          Lynr::Config.new(nil, nil, { dataone_decode: true })
        end
      end

      it "can't find '1HG' in cache" do
        expect(Lynr.cache.include?('1HG')).to be_false
      end

      it 'fetches dataone_response for 1HG' do
        expect(api.fetch('1HG')).to be_instance_of(LibXML::XML::Node)
      end

      it 'stores response in cache' do
        node = api.fetch('1HG')
        expect(Lynr.cache.include?('1HG')).to be_true
      end

    end

    context 'with active DB and no decode', :if => (MongoHelpers.connected?) do

      before(:each) do
        Lynr.stub(:features) do |type, defaults|
          Lynr::Config.new(nil, nil, { dataone_decode: false })
        end
      end

      it "can't find '1HG' in cache" do
        expect(Lynr.cache.include?('1HG')).to be_false
      end

      it 'gets nil if not decoding' do
        expect(api.fetch('1HG')).to be_nil
      end

    end

  end

end
