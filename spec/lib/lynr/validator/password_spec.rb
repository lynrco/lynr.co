require 'rspec/autorun'
require './lib/lynr/validator'

describe Lynr::Validator::Password do

  class Dummy
    include Lynr::Validator::Password
  end

  let(:helpers) { Dummy.new }

  describe "#error_for_passwords" do

    it "gives an error if password too short" do
      expect(helpers.error_for_passwords("hi", "hi")).to eq("Your password must be at least 3 characters.")
    end

    it "gives an error if password and confirm do not match" do
      expect(helpers.error_for_passwords("masta", "master")).to eq("Your passwords don't match.")
    end

    it "is nil if password is long enough and matches confirm" do
      expect(helpers.error_for_passwords("masta", "masta")).to be_nil
    end

  end

  describe "#is_valid_password?" do

    it "passes a sufficient password" do
      expect(helpers.is_valid_password?("hi there")).to be_true
    end

    it "fails a short password" do
      expect(helpers.is_valid_password?("hi")).to be_false
    end

  end

end
