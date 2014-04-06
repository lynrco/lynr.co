require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/persist/mongo_dao'

describe Lynr::Persist::MongoDao do

  before(:each) do
    @environment = ENV['whereami']
    ENV['whereami'] = 'neverland'
  end

  after(:each) do
    ENV['whereami'] = @environment
  end

  let(:client) { dao.client }
  let(:config) {
    {
      'host' => '127.0.0.1',
      'port' => '27017',
      'database' => 'lynr_spec',
      'collection' => 'dummy',
    }
  }
  let(:dao) { Lynr::Persist::MongoDao.new(config) }

  describe "#initialize" do

    it "creates a dao successfully" do
      expect { Lynr::Persist::MongoDao.new }.to be
    end

    context "with active connection", :if => (MongoHelpers.connected?) do

      it "creates dao with client" do
        expect(dao.client).to be
      end

    end

  end # initialize

  describe "#uri" do

    it "is mongodb://127.0.0.1:27017/lynr_spec" do
      expect(dao.uri).to eq("mongodb://127.0.0.1:27017/lynr_spec")
    end

    it "is based on config properties" do
      expect(dao.uri).to eq("mongodb://#{config['host']}:#{config['port']}/#{config['database']}")
    end

    context "with only uri in config" do

      let(:config) { { 'uri' => 'mongodb://foo:bar@lynr.co:18000/lynrco' } }

      it "comes from config if config has uri" do
        expect(dao.uri).to eq('mongodb://foo:bar@lynr.co:18000/lynrco')
      end

      it "only has uri key" do
        expect(config.keys).to eq(['uri'])
      end

    end

    context "with credentials" do

      let(:config) {
        {
          'host' => '127.0.0.1',
          'port' => '27017',
          'database' => 'lynr_spec',
          'user' => 'foo',
          'pass' => 'bar',
          'collection' => 'dummy',
        }
      }

      it "includes user and pass in uri" do
        expect(dao.uri).to eq("mongodb://#{config['user']}:#{config['pass']}@\
#{config['host']}:#{config['port']}/#{config['database']}")
      end

    end

    context "with uri and all connection properties in config" do

      let(:config) {
        {
          'uri'  => 'mongodb://foo:bar@lynr.co:18000/lynrco',
          'host' => '127.0.0.1',
          'port' => '27017',
          'database' => 'lynr_spec',
          'user' => 'foo',
          'pass' => 'bar',
          'collection' => 'dummy',
        }
      }

      it "uses uri value from config" do
        expect(dao.uri).to eq(config['uri'])
      end

    end

  end # uri

  describe "#config" do

    it "has a host" do
      expect(dao.config.host).to be
    end

    it "has a port" do
      expect(dao.config.port).to be
    end

    it "has a database" do
      expect(dao.config.database).to be
    end

  end # config

  describe "#credentials" do

    it "is user:pass when user and pass are in config" do
      config['user'] = 'foo'
      config['pass'] = 'bar'
      expect(dao.credentials).to eq("#{config['user']}:#{config['pass']}")
    end

    it "is nil when user in config without pass" do
      config['user'] = 'foo'
      expect(dao.credentials).to be_nil
    end

    it "is nil when pass in config without user" do
      config['pass'] = 'bar'
      expect(dao.credentials).to be_nil
    end

    it "is nil when neither user nor pass are in config" do
      expect(dao.credentials).to be_nil
    end

  end

  describe "#credentials?" do

    it "is true when user and pass are in config" do
      config['user'] = 'foo'
      config['pass'] = 'bar'
      expect(dao.credentials?).to be_true
    end

    it "is false when user in config without pass" do
      config['user'] = 'foo'
      expect(dao.credentials?).to be_false
    end

    it "is false when pass in config without user" do
      config['pass'] = 'bar'
      expect(dao.credentials?).to be_false
    end

    it "is false when neither user nor pass are in config" do
      expect(dao.credentials?).to be_false
    end

  end

  context "no config provided" do

    let(:dao) { Lynr::Persist::MongoDao.new }

    describe "#config" do

      it "has host from MongoDefaults" do
        expect(dao.config.host).to eq(Lynr::Persist::MongoDao::MongoDefaults['host'])
      end

      it "has port from MongoDefaults" do
        expect(dao.config.port).to eq(Lynr::Persist::MongoDao::MongoDefaults['port'])
      end

      it "has database from MongoDefaults" do
        expect(dao.config.database).to eq(Lynr::Persist::MongoDao::MongoDefaults['database'])
      end

    end

  end

  # NOTE: These specs use the configuration in `config/database.spec.yaml`
  context "with active connection", :if => (MongoHelpers.connected?) do

    # Reset whereami environment variable
    before(:each) do
      ENV['whereami'] = @environment
    end

    let(:dao) { MongoHelpers.dao }

    context "configured environment" do

      it "has a config property" do
        expect(dao.config).not_to eq(nil)
      end

      it "creates a dao with client" do
        expect(dao.client).to be
      end

      describe "#client" do

        it "has host that matches config" do
          expect(client.host).to eq(dao.config.host)
        end

        it "has port that matches config" do
          expect(client.port.to_s).to eq(dao.config.port)
        end

      end

    end

    describe "#client" do

      it "has a host of localhost" do
        expect(dao.client.host).to eq('127.0.0.1')
      end

      it "has a port of 27017" do
        expect(dao.client.port).to eq(27017)
      end

    end # client

    describe "#count" do

      before(:each) do
        dao.save({ 'price' => 13532 })
        dao.save({ 'price' => 13535 })
        dao.save({ 'price' => 13538 })
        dao.save({ 'price' => 13541 })
        dao.save({ 'price' => 13544 })
      end

      it "counts all with no query" do
        expect(dao.count).to eq(5)
      end

      it "counts according to query" do
        expect(dao.count({ 'price' => 13532 })).to eq(1)
      end

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

    end # CRUD

  end # with active connection

end
