require 'rspec/autorun'
require './lib/lynr/validator/helpers'

describe Lynr::Validator::Helpers do

  class Dummy
    include Lynr::Validator::Helpers
  end

  let(:helpers) { Dummy.new }
  let(:post) {
    {
      'hi' => '',
      'foo' => 'bar',
      'boo' => "baz"
    }
  }

  describe "#is_valid_email?" do

    it "passes well formed email addresses" do
      expect(helpers.is_valid_email?("help@gmail.com")).to be_true
    end

    it "fails with no @ in email" do
      expect(helpers.is_valid_email?("hitheregmail.om")).to be_false
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
      domain = "thisismylongdomainpartthisismylongdomainpartthisismylongdomainpart\
thisismylongdomainpartthisismylongdomainpartthisismylongdomainpartthisismylongdomainpart\
thisismylongdomainpartthisismylongdomainpartthisismylongdomainpartthisismylongdomainpart\
thisismylon.com"
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

#    Valid test but causes network traffic which can be slow
#    it "fails with invalid domain" do
#      expect(helpers.is_valid_email?("hi.there@idonthinkthisdomainwillhavedns.com")).to be_false
#    end

  end

  describe "#is_valid_password?" do

    it "passes a sufficient password" do
      expect(helpers.is_valid_password?("hi there")).to be_true
    end

    it "fails a short password" do
      expect(helpers.is_valid_password?("hi")).to be_false
    end

  end

  describe "#validate_required" do

    it "returns empty `Hash` when no fields provided" do
      expect(helpers.validate_required(post, [])).to eq({})
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

end
