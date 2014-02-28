require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/dealership'
require './lib/lynr/persist/dealership_dao'
require './lib/lynr/validator'

describe Lynr::Validator::Helpers do

  class Dummy
    include Lynr::Validator::Helpers
  end

  let(:dealer) { Lynr::Model::Dealership.new({ 'slug' => 'carmax-san-diego', 'identity' => identity }) }
  let(:dao) { Lynr::Persist::DealershipDao.new }
  let(:helpers) { Dummy.new }
  let(:identity) { Lynr::Model::Identity.new('bryan@lynr.co', 'this is a fake password') }
  let(:post) {
    {
      'hi' => '',
      'foo' => 'bar',
      'boo' => "baz",
      'oops' => nil,
    }
  }

  describe "#validate_required" do

    it "returns empty `Hash` when no fields provided" do
      expect(helpers.validate_required(post, [])).to eq({})
    end

    it "returns a `Hash` with key for field if post contains nil value for field" do
      errors = helpers.validate_required(post, ['oops'])
    end

    it "returns `Hash` with key for field if post doesn't contain field" do
      errors = helpers.validate_required(post, ['jumper'])
      expect(errors).to include('jumper')
    end

    it "returns `Hash` with key for field if post contains field with empty value" do
      errors = helpers.validate_required(post, ['hi'])
      expect(errors).to include('hi')
    end

    it "returns empty `Hash` when fields contain non-empty values" do
      errors = helpers.validate_required(post, ['foo', 'boo'])
      expect(errors).to eq({})
    end

  end

  describe "#is_valid_slug?" do

    it "returns false if empty" do
      expect(helpers.is_valid_slug?("")).to be_false
    end

    it "returns false if nil" do
      expect(helpers.is_valid_slug?(nil)).to be_false
    end

    it "returns true if all lowercase letters" do
      expect(helpers.is_valid_slug?('alllettershere')).to be_true
    end

    it "returns true if all hyphens" do
      expect(helpers.is_valid_slug?('---')).to be_true
    end

    it "returns true if all lowercase or hyphens" do
      expect(helpers.is_valid_slug?('say-hi')).to be_true
    end

    it "returns true if valid object id" do
      expect(helpers.is_valid_slug?(BSON::ObjectId.from_time(Time.now).to_s)).to be_true
    end

    it "returns false if contains uppercase letters" do
      expect(helpers.is_valid_slug?('Say-hi')).to be_false
    end

    it "returns true if contains letters and numbers" do
      expect(helpers.is_valid_slug?('say7hi')).to be_true
    end

    it "returns true if contains numbers and hyphens" do
      expect(helpers.is_valid_slug?('7-11')).to be_true
    end

    it "returns true if contains letters, numbers and hyphens" do
      expect(helpers.is_valid_slug?('welcome-7-11')).to be_true
    end

  end

  context "with mongo connection", :if => (MongoHelpers.connected?) do

    before(:each) do
      MongoHelpers.empty! if MongoHelpers.connected?
    end

    describe "#error_for_slug" do

      it "gives an error if slug is invalid" do
        expect(helpers.error_for_slug(dao, "Say-hi")).to eq(\
          "Dealership handle may contain only lowercase letters, numbers and hyphens.")
      end

      it "gives an error if slug is in use" do
        dao.save(dealer)
        expect(helpers.error_for_slug(dao, "carmax-san-diego")).to eq(\
          "Dealership handle, <em>carmax-san-diego</em>, is in use by someone else.")
      end

      it "gives nil if slug valid and not in use" do
        expect(helpers.error_for_slug(dao, "say-hi")).to be_nil
      end

    end

  end

end
