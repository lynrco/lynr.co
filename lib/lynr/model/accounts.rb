require './lib/lynr/model/ebay_account'

module Lynr::Model

  # # `Lynr::Model::Accounts`
  #
  # Given an array of Account records, filter the known account types to make them
  # accessible.
  #
  class Accounts

    # ## `Accounts.new(data)`
    #
    # Create `Accounts` with `data`. `data` is an `Array` of `Hash` instances representing
    # external account types. Known account types are:
    #
    # * `Lynr::Model::EbayAccount`
    #
    def initialize(data=[])
      @data = data || []
    end

    # ## `Accounts#ebay`
    #
    # Get the `EbayAccount` from the `data` provided to the constructor. Provides an
    # empty and expired `EbayAccount` if no `Hash` of type `EbayAccount::TYPE` was
    # provided.
    #
    def ebay
      return @ebay unless @ebay.nil?
      ebay_data = @data.find { |a| a['type'] == EbayAccount::TYPE }
      @ebay = EbayAccount.inflate(ebay_data)
    end

    # ## `Accounts#view`
    #
    # Create a primitives only representation of this `Accounts` instance.
    #
    def view
      view_data = []
      view_data.push(ebay.view) unless ebay.empty?
      view_data
    end

    # `Accounts.inflate` behaves exactly like `Accounts.new` so alias it.
    class << self
      alias :inflate :new
    end

  end

end
