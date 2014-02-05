require 'rspec/autorun'
require './spec/spec_helper'

require 'bson'
require './lib/lynr/persist/dao'

describe Lynr::Persist::Dao do

  class DaoDummy

    attr_reader :id, :expires

    def initialize(data={})
      @id = data.fetch('id', nil)
      @expires = data.fetch('expires', Time.now + 86400)
    end

    def view
      {
        'id' => @id,
        'class' => self.class.name,
        'expires' => @expires,
      }
    end

    def self.inflate(record)
      data = record || {}
      DaoDummy.new(data)
    end

  end

  let(:dao) { Lynr::Persist::Dao.new }
  let(:token) { DaoDummy.new }

  context "with active connection", :if => (MongoHelpers.connected?) do

    before(:each) do
      MongoHelpers.empty! if MongoHelpers.connected?
    end

    describe "#create result" do

      it "is a DaoDummy instance" do
        expect(dao.create(token)).to be_an_instance_of(DaoDummy)
      end

      it "has the same data" do
        saved = dao.create(token)
        expect(saved.expires).to eq(token.expires)
      end

      it "has an id" do
        expect(token.id).to be_nil
        saved = dao.create(token)
        expect(saved.id).to be
      end

    end

    describe "#include?" do

      it "is false when record does not exists" do
        expect(dao.include?(BSON::ObjectId.from_time(Time.now))).to be_false
      end

      it "is true when record exists" do
        saved = dao.create(token)
        expect(dao.include?(saved.id)).to be_true
      end

    end

    describe "#read result" do

      context "when record doesn't exist" do

        it "is nil" do
          expect(dao.read(BSON::ObjectId.from_time(Time.now))).to be_nil
        end

      end

      context "when record exists" do

        let(:saved) { dao.create(token) }

        it "is a DaoDummy instance" do
          expect(dao.read(saved.id)).to be_an_instance_of(DaoDummy)
        end

        it "has the right id" do
          read = dao.read(saved.id)
          expect(read.id).to eq(saved.id)
        end

        it "has the same data" do
          read = dao.read(saved.id)
          expect(read.expires.to_i).to eq(saved.expires.to_i)
        end

      end

    end

    describe "#delete" do

      context "when record does not exist" do

        it "returns Mongo error Hash" do
          expect(dao.delete(BSON::ObjectId.from_time(Time.now))).to be_false
        end

      end

      context "when record does exist" do

        let(:saved) { dao.create(token) }

        it "returns true" do
          id = saved.id
          expect(dao.delete(id)).to be_true
          expect(dao.read(id)).to be_nil
        end

      end

    end

  end

end
