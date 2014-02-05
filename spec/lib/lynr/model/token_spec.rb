require 'rspec/autorun'
require './spec/spec_helper'

require 'bson'

require './lib/lynr/model/token'

describe Lynr::Model::Token do

  let(:dealership) { BSON::ObjectId.from_time(Time.now) }
  let(:now) { Time.now }

  describe ".new" do

    it "raises argument error if no dealership" do
      expect { Lynr::Model::Token.new }.to raise_error(ArgumentError)
    end

  end

  describe "#==" do

    context "when id is `nil`" do

      it "returns true when dealership and expires match" do
        t1 = Lynr::Model::Token.new('dealership' => dealership, 'expires' => now)
        t2 = Lynr::Model::Token.new('dealership' => dealership, 'expires' => now)
        expect(t1).to eq(t2)
      end

      it "returns false when dealership doesn't match" do
        t1 = Lynr::Model::Token.new('dealership' => dealership, 'expires' => now)
        dealership = BSON::ObjectId.from_string('52f274d40000000000000000')
        t2 = Lynr::Model::Token.new('dealership' => dealership, 'expires' => now)
        expect(t1).to_not eq(t2)
      end

      it "returns false when expires doesn't match" do
        t1 = Lynr::Model::Token.new('dealership' => dealership, 'expires' => now)
        now = Time.now
        t2 = Lynr::Model::Token.new('dealership' => dealership, 'expires' => now)
        expect(t1).to_not eq(t2)
      end

    end

    context "when id is set" do

      let(:id) { "345678" }

      it "returns true when dealership and expires match" do
        t1 = Lynr::Model::Token.new('id' => id, 'dealership' => dealership, 'expires' => now)
        t2 = Lynr::Model::Token.new('id' => id, 'dealership' => dealership, 'expires' => now)
        expect(t1).to eq(t2)
      end

      it "returns false when dealership doesn't match" do
        t1 = Lynr::Model::Token.new('id' => id, 'dealership' => dealership, 'expires' => now)
        dealership = BSON::ObjectId.from_string('52f274d40000000000000000')
        t2 = Lynr::Model::Token.new('id' => id, 'dealership' => dealership, 'expires' => now)
        expect(t1).to_not eq(t2)
      end

      it "returns false when expires doesn't match" do
        t1 = Lynr::Model::Token.new('id' => id, 'dealership' => dealership, 'expires' => now)
        now = Time.now
        t2 = Lynr::Model::Token.new('id' => id, 'dealership' => dealership, 'expires' => now)
        expect(t1).to_not eq(t2)
      end

    end

  end

  describe "#expired?" do

    it "is true if `token.expires` is before now" do
      token = Lynr::Model::Token.new('dealership' => dealership, 'expires' => (Time.now - 1))
      expect(token.expired?).to be_true
    end

    it "is false if `token.expires` is after now" do
      token = Lynr::Model::Token.new('dealership' => dealership, 'expires' => (Time.now + 1000))
      expect(token.expired?).to be_false
    end

  end

end
