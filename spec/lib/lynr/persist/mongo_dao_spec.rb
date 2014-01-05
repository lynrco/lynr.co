require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/persist/mongo_dao'

describe Lynr::Persist::MongoDao do

  before(:each) do
    root = RSpec.configuration.root
    whereami = RSpec.configuration.whereami
    @config = YAML.load_file("#{root}/config/database.#{whereami}.yaml")
  end

  let!(:dao) { MongoHelpers.dao }

  describe "#initialize" do

    context "unconfigured environment" do

      before(:each) do
        @environment = ENV['whereami']
      end

      after(:each) do
        ENV['whereami'] = @environment
      end

      it "uses defaults" do
        ENV['whereami'] = 'neverland'
        expect { Lynr::Persist::MongoDao.new }.to be
      end

    end

    context "configured environment" do

      it "has a config property" do
        expect(dao.config).not_to eq(nil)
      end

    end

  end

  describe "#config" do

    it "has a host" do
      expect(dao.config['host']).to be
    end

    it "has a port" do
      expect(dao.config['port']).to be
    end

    it "has a database" do
      expect(dao.config['database']).to be
    end

  end

  context "with active connection", :if => (MongoHelpers.connected?) do

    after(:each) do
      dao.collection.remove() if MongoHelpers.dao.active?
    end

    describe "#save" do

      let(:record) { { 'price' => 13532 } }

      it "gives an object the id property" do
        expect(dao.save(record)['_id']).not_to eq(nil)
      end

      it "updates a record with an id" do
        car = dao.save(record)
        id = car['_id']
        car['price'] = record['price'] * 1.05
        expect(dao.save(car, id)['price']).to eq(record['price'] * 1.05)
        expect(dao.read(id)['price']).to eq(record['price'] * 1.05)
      end

      it "keeps id for updated records" do
        car = dao.save(record)
        id = car['_id']
        car['price'] = record['price'] * 1.05
        expect(dao.save(car, id)['_id']).to eq(id)
      end

    end # save

    describe "#search" do

      let(:records) {
        [
          { name: 'Bryan', role: 'Technology' },
          { name: 'Darrell', role: 'Creative' },
          { name: 'Kevin', role: 'Legal' }
        ]
      }

      before(:each) do
        records.map { |record| dao.save(record) }
      end

      it "Gives one record when limit = 1" do
        expect(dao.search({ name: 'Bryan' }, limit: 1)).to be_kind_of(Hash)
      end

      it "Gives multiple records (Enumerable) when limit != 1" do
        expect(dao.search({})).to be_kind_of(Enumerable)
      end

    end # search

    describe "CRUD" do

      let(:record) { { name: 'Bryan', role: 'Technology' } }

      it "creates records and assigns ids" do
        id = dao.create(record)
        expect(id).to be_instance_of(BSON::ObjectId)
      end

      it "reads existing records" do
        id = dao.create(record)
        read = dao.read(id)
        expect(read['_id']).to eq(id)
      end

      it "updates existing records" do
        id = dao.create(record)
        record[:role] = 'Different'
        expect(dao.update(id, record)).to be_true
        read = dao.read(id)
        expect(read['role']).to eq('Different')
      end

      it "deletes existing records" do
        id = dao.create(record)
        expect(dao.delete(id)).to be_true
        read = dao.read(id)
        expect(read).to be_nil
      end

      it "reads nil for non-existent ids" do
        read = dao.read('test_id')
        expect(read).to be_nil
      end

    end

  end

end
