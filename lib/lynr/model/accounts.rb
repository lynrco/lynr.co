require './lib/lynr/model/ebay_account'

module Lynr::Model

  # # `Lynr::Model::Accounts`
  #
  # Given an array of Account records, filter the known account types to make them
  # accessible.
  #
  class Accounts

    def initialize(data=[])
      @data = data || []
    end

    def ebay
      return @ebay unless @ebay.nil?
      ebay_data = @data.find { |a| a['type'] == EbayAcount::TYPE }
      @ebay = EbayAccount.inflate(ebay_data)
    end

    def view
      view_data = []
      view_data.push(ebay.view) unless ebay.empty?
      view_data
    end

    def self.inflate(data)
      Accounts.new(data)
    end

  end

end
