require 'rspec/autorun'
require './lib/lynr/validator/helpers'

describe Lynr::Validator::Helpers do

  class Dummy
    include Lynr::Validator::Helpers
  end

  let(:helpers) { Dummy.new }

  describe "#is_valid_email?" do

    it "passes well formed email addresses" do
      expect(helpers.is_valid_email?("help@gmail.com")).to be_true
    end

    it "fails emails with no local/username part" do
      expect(helpers.is_valid_email?("@gmail.com")).to be_false
    end

    it "fails emails with long local/username part" do
      local = "thisismylonglocalpartthisismylonglocalpartthisismylonglocalpartth"
      expect(local.length).to be > 64
      expect(helpers.is_valid_email?("#{local}@gmail.com")).to be_false
    end

    it "fails with no doamin part" do
      expect(helpers.is_valid_email?("username@")).to be_false
    end

    it "fails emails with long domain part" do
      domain = "thisismylongdomainpartthisismylongdomainpartthisismylongdomainpartthisismylongdomainpartthisismylongdomainpartthisismylongdomainpartthisismylongdomainpartthisismylongdomainpartthisismylongdomainpartthisismylongdomainpartthisismylongdomainpartthisismylon.gd"
      expect(domain.length).to be > 255
      expect(helpers.is_valid_email?("username@#{domain}")).to be_false
    end

    it "fails with local/username containing '..'" do
      expect(helpers.is_valid_email?("hi..there@gmail.com")).to be_false
    end

    it "fails with non-alphanumeric (plus hyphen or period) domain" do
      expect(helpers.is_valid_email?("hi.there@+gmail.com")).to be_false
    end

    it "fails with domain containing '..'" do
      expect(helpers.is_valid_email?("hi.there@gmail..com")).to be_false
    end

  end

end
