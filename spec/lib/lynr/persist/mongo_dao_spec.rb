require 'rspec/autorun'
require 'yaml'
require './lib/lynr/persist/mongo_dao'

describe Lynr::Persist::MongoDao do

  before(:each) do
    ENV['whereami'] = 'test'
    @config = YAML.load_file("config/database.#{ENV['whereami']}.yaml")
  end

  let(:dao) { Lynr::Persist::MongoDao.new(collection='dummy') }

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

  describe "#save" do

    let(:record) { { price: 13532 } }

    before(:each) do
      # This requires a little inside baseball on what MongoDao does
      # calls to save use create to actually hit the database if there
      # isn't already an id field
      # Note: this is kind of cheating
      dao.stub(:create) do |record|
        record[:id] = 789
        record
      end
    end

    it "gives an object the id property" do
      expect(dao.save(record)[:id]).not_to eq(nil)
    end

  end

end
