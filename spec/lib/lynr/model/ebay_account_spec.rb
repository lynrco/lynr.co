require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/ebay_account'

describe Lynr::Model::EbayAccount do

  let(:account) {
    Lynr::Model::EbayAccount.new(
      'expires' => DateTime.parse('2015-07-02T23:36:35.000Z'),
      'session' => '+3cCAA**69b135111430a471d220cf50ffffff72',
      'token'   => 'YourAuthToken',
    )
  }
  let(:empty_account) { Lynr::Model::EbayAccount.new }

  describe "#view" do

    it "has an expires property" do
      expect(account.view).to include('expires')
    end

    it "has a session property" do
      expect(account.view).to include('session')
    end

    it "has a token property" do
      expect(account.view).to include('token')
    end

  end

  describe "#==" do

    it "is true if all properties are equal" do
      a = Lynr::Model::EbayAccount.new(
        'expires' => DateTime.parse('2015-07-02T23:36:35.000Z'),
        'session' => '+3cCAA**69b135111430a471d220cf50ffffff72',
        'token'   => 'YourAuthToken',
      )
      expect(a).to eq(account)
    end

    it "is true if token and expires are equal" do
      a = Lynr::Model::EbayAccount.new(
        'expires' => DateTime.parse('2015-07-02T23:36:35.000Z'),
        'session' => 'YourSessionValue',
        'token'   => 'YourAuthToken',
      )
      expect(a).to eq(account)
    end

    it "is false if token valures are not equal" do
      a = Lynr::Model::EbayAccount.new(
        'expires' => DateTime.parse('2015-07-02T23:36:35.000Z'),
        'session' => '+3cCAA**69b135111430a471d220cf50ffffff72',
        'token'   => 'YourOtherAuthToken',
      )
      expect(a).to_not eq(account)
    end

    it "is false if expires values are not equal" do
      a = Lynr::Model::EbayAccount.new(
        'expires' => DateTime.parse('2014-07-02T23:36:35.000Z'),
        'session' => '+3cCAA**69b135111430a471d220cf50ffffff72',
        'token'   => 'YourAuthToken',
      )
      expect(a).to_not eq(account)
    end

  end

  describe ".inflate" do

    it "creates equivalent account instances from properties" do
      a = Lynr::Model::EbayAccount.inflate(
        'expires' => DateTime.parse('2015-07-02T23:36:35.000Z'),
        'session' => '+3cCAA**69b135111430a471d220cf50ffffff72',
        'token'   => 'YourAuthToken',
      )
      expect(a).to eq(account)
    end

    it "provides an empty account for nil" do
      expect(Lynr::Model::EbayAccount.inflate(nil)).to eq(empty_account)
    end

  end

end
