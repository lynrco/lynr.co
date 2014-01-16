require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/model/ebay_account'

describe Lynr::Model::EbayAccount do

  let(:account) {
    Lynr::Model::EbayAccount.new(
      'expires' => Time.parse('2015-07-02T23:36:35.000Z'),
      'session' => '+3cCAA**69b135111430a471d220cf50ffffff72',
      'token'   => 'YourAuthToken',
    )
  }
  let(:empty_account) { Lynr::Model::EbayAccount.new }

  describe "empty?" do

    it "is true if session is nil and token is nil" do
      account = Lynr::Model::EbayAccount.new('session' => nil, 'token' => nil)
      expect(account.empty?).to be_true
    end

    it "is true if session is nil and token is empty" do
      account = Lynr::Model::EbayAccount.new('session' => nil, 'token' => '')
      expect(account.empty?).to be_true
    end

    it "is true if session is empty and token is nil" do
      account = Lynr::Model::EbayAccount.new('session' => '', 'token' => nil)
      expect(account.empty?).to be_true
    end

    it "is true if session is empty and token is empty" do
      account = Lynr::Model::EbayAccount.new('session' => '', 'token' => '')
      expect(account.empty?).to be_true
    end

    it "is true if session is empty and token is empty" do
      account = Lynr::Model::EbayAccount.new('session' => '', 'token' => '')
      expect(account.empty?).to be_true
    end

    it "is true if session is not empty and token is empty" do
      account = Lynr::Model::EbayAccount.new('session' => 'Hi', 'token' => '')
      expect(account.empty?).to be_true
    end

    it "is true if session is empty and token is not empty" do
      account = Lynr::Model::EbayAccount.new('session' => '', 'token' => 'Hi')
      expect(account.empty?).to be_true
    end

    it "is false if session is not empty and token is not empty" do
      account = Lynr::Model::EbayAccount.new('session' => 'Hi', 'token' => 'Hi')
      expect(account.empty?).to be_false
    end

  end

  describe "#expired?" do

    it "is true for an default EbayAccount" do
      account = Lynr::Model::EbayAccount.new
      expect(account.expired?).to be_true
    end

    it "is true if expires is before now" do
      account = Lynr::Model::EbayAccount.new('expires' => DateTime.now.prev_day.to_time)
      expect(account.expired?).to be_true
    end

    it "is true if expires is now" do
      account = Lynr::Model::EbayAccount.new('expires' => Time.now)
      expect(account.expired?).to be_true
    end

    it "is false if expires is after now" do
      account = Lynr::Model::EbayAccount.new('expires' => DateTime.now.next_day.to_time)
      expect(account.expired?).to be_false
    end

  end

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

    it "has a type property" do
      expect(account.view).to include('type')
    end

    it "has a type == 'eBay'" do
      expect(account.view['type']).to eq('eBay')
    end

  end

  describe "#==" do

    it "is true if all properties are equal" do
      a = Lynr::Model::EbayAccount.new(
        'expires' => Time.parse('2015-07-02T23:36:35.000Z'),
        'session' => '+3cCAA**69b135111430a471d220cf50ffffff72',
        'token'   => 'YourAuthToken',
      )
      expect(a).to eq(account)
    end

    it "is true if token and expires are equal" do
      a = Lynr::Model::EbayAccount.new(
        'expires' => Time.parse('2015-07-02T23:36:35.000Z'),
        'session' => 'YourSessionValue',
        'token'   => 'YourAuthToken',
      )
      expect(a).to eq(account)
    end

    it "is false if token valures are not equal" do
      a = Lynr::Model::EbayAccount.new(
        'expires' => Time.parse('2015-07-02T23:36:35.000Z'),
        'session' => '+3cCAA**69b135111430a471d220cf50ffffff72',
        'token'   => 'YourOtherAuthToken',
      )
      expect(a).to_not eq(account)
    end

    it "is false if expires values are not equal" do
      a = Lynr::Model::EbayAccount.new(
        'expires' => Time.parse('2014-07-02T23:36:35.000Z'),
        'session' => '+3cCAA**69b135111430a471d220cf50ffffff72',
        'token'   => 'YourAuthToken',
      )
      expect(a).to_not eq(account)
    end

  end

  describe ".inflate" do

    it "creates equivalent account instances from properties" do
      a = Lynr::Model::EbayAccount.inflate(
        'expires' => Time.parse('2015-07-02T23:36:35.000Z'),
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
