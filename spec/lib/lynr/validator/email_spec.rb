require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/dealership'
require './lib/lynr/persist/dealership_dao'
require './lib/lynr/validator'

describe Lynr::Validator::Email do

  class Dummy
    include Lynr::Validator::Email
  end

  let(:dealer) { Lynr::Model::Dealership.new({ 'identity' => identity }) }
  let(:dao) { Lynr::Persist::DealershipDao.new }
  let(:helpers) { Dummy.new }
  let(:identity) { Lynr::Model::Identity.new('bryan@lynr.co', 'this is a fake password') }

  context "with mongo connection", :if => (MongoHelpers.connected?) do

    describe "#error_for_email" do

      it "gives an error if email is invalid" do
        expect(helpers.error_for_email(dao, "@gmail.com")).to eq("Check your email address.")
      end

      it "gives an error if email is taken" do
        dao.save(dealer)
        expect(helpers.error_for_email(dao, "bryan@lynr.co")).to eq("bryan@lynr.co is already taken.")
      end

      it "gives nil if email valid and not taken" do
        expect(helpers.error_for_email(dao, "bryan+test@lynr.co")).to be_nil
      end

    end

  end

  describe "#is_valid_email?" do

    ["help@gmail.com", "mail@bryanwrit.es"].each do |email|

      it "passes well formed email addresses - #{email}" do
        expect(helpers.is_valid_email?(email)).to be_true
      end

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

#    Valid test but causes network traffic timeout which can be slow
    it "fails with invalid domain" do
      expect(helpers.is_valid_tld?("idonthinkthisdomainwillhavedns.com")).to be_false
    end

  end


end
