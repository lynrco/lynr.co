require './lib/lynr/model/accounts'

describe Lynr::Model::Accounts do

  let(:ebay_account) {
    Lynr::Model::EbayAccount.new(
      'expires' => Time.parse('2015-07-02T23:36:35.000Z'),
      'session' => '+3cCAA**69b135111430a471d220cf50ffffff72',
      'token'   => 'YourAuthToken',
    )
  }
  let(:empty_accounts) { Lynr::Model::Accounts.new }
  let(:accounts) {
    Lynr::Model::Accounts.new([ ebay_account.view ])
  }

  describe "#ebay" do

    it "is empty EbayAccount for empty Accounts" do
      expect(empty_accounts.ebay.empty?).to be_true
    end

    it "is not empty EbayAccount for Accounts with eBay type" do
      expect(accounts.ebay.empty?).to be_false
    end

    it "is equivalent to account whose view was used" do
      expect(accounts.ebay).to eq(ebay_account)
    end

    it "gets the EbayAccount when Accounts isn't given a view" do
      accounts = Lynr::Model::Accounts.new([ ebay_account ])
      expect(accounts.ebay).to eq(ebay_account)
    end

  end

  describe "#view" do

    it "is an array" do
      expect(accounts.view).to be_a(Array)
    end

    it "contains `Hash` instances" do
      accounts.view.each { |v| expect(v).to be_a(Hash) }
    end

    it "contains an ebay account Hash" do
      expect(accounts.view).to include(ebay_account.view)
    end

  end

end
