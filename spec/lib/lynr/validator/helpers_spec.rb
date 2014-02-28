require 'rspec/autorun'
require './lib/lynr/validator'

describe Lynr::Validator::Helpers do

  class Dummy
    include Lynr::Validator::Helpers
  end

  let(:helpers) { Dummy.new }
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

  end

end
