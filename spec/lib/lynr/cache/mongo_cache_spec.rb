require 'rspec/autorun'
require './spec/spec_helper'
require './spec/lib/lynr/cache_specs_shared'

require './lib/lynr/cache/mongo_cache'

describe Lynr::Cache::MongoCache do

  let(:cn) { 'lynr_cache' }
  let(:cache) { described_class.new({ 'collection' => cn }) }

  it_behaves_like Lynr::Cache if MongoHelpers.connected?

  describe "#available?" do

    context "no config file" do

      before(:each) do
        @whereami = RSpec.configuration.whereami
        ENV['whereami'] = 'none'
      end

      after(:each) do
        ENV['whereami'] = @whereami
      end

      it "is false when mongo configuration does not exist" do
        expect(cache.available?).to be_false
      end

    end

    it "is false when mongo configuration exists but can't connect" do
      c = described_class.new('port' => '27018')
      expect(c.available?).to be_false
    end

    it "is true when mongo configuration is valid", :if => (MongoHelpers.connected?) do
      expect(cache.available?).to be_true
    end

  end

  context "with active connection", :if => (MongoHelpers.connected?) do

    let(:dao) { MongoHelpers.dao(cn) }

    after(:each) do
      dao.collection.remove() if MongoHelpers.dao.active?
    end

    describe "#write" do

      it "creates a document with _id = key" do
        cache.write(:foo, 'bar')
        expect(dao.read(:foo)).to_not be_nil
      end

      it "creates a document with v = value" do
        cache.write(:foo, 'bar')
        expect(dao.read(:foo)['v']).to eq('bar')
      end

    end

  end

end
