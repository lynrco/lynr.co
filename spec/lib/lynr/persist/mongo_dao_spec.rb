require 'rspec/autorun'
require 'yaml'
require './lib/lynr/persist/mongo_dao'

class MongoHelpers
  def self.dao
    Lynr::Persist::MongoDao.new(collection='dummy')
  end
end

describe Lynr::Persist::MongoDao do

  before(:each) do
    ENV['whereami'] = 'test'
    @config = YAML.load_file("config/database.#{ENV['whereami']}.yaml")
  end

  let!(:dao) { MongoHelpers.dao }

  describe "#initialize" do

    context "unconfigured environment" do

      it "raises an Error in an unknown environment" do
        ENV['whereami'] = 'neverland'
        expect { Lynr::Persist::MongoDao.new }.to raise_error(Errno::ENOENT)
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
      expect(dao.config['host']).to eq(@config['mongo']['host'])
    end

    it "has a port" do
      expect(dao.config['port']).to eq(@config['mongo']['port'])
    end

    it "has a database" do
      expect(dao.config['database']).to eq(@config['mongo']['database'])
    end

  end

  context "with active connection", :if => (MongoHelpers.dao.active?) do

    after(:each) do
      dao.collection.remove() if MongoHelpers.dao.active?
    end

    describe "#save" do

      let(:record) { { price: 13532 } }

      it "gives an object the id property" do
        expect(dao.save(record)[:id]).not_to eq(nil)
      end

      it "updates a record with an id" do
        car = dao.save(record)
        id = car[:id]
        car[:price] = record[:price] * 1.05
        expect(dao.save(car, id)[:price]).to eq(record[:price] * 1.05)
        expect(dao.read(id)['price']).to eq(record[:price] * 1.05)
      end

    end

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

    end

  end

end
