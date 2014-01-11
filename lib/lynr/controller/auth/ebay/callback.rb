require 'yaml'

require './lib/ebay'
require './lib/lynr/cache'
require './lib/lynr/model/accounts'
require './lib/lynr/model/dealership'
require './lib/lynr/model/ebay_account'
require './lib/lynr/persist/dealership_dao'

module Lynr::Controller

  # # `Lynr::Controller::Ebay::Callback`
  #
  # Resource/Controller class to handle the case where authentication with eBay
  # succeeds.
  #
  class Ebay::Callback < Lynr::Controller::Admin

    get  '/auth/ebay/callback', :get

    def initialize
      super
      @title = "Callback Success"
    end

    # ## `Ebay::Callback#get(req)
    #
    # Process `req` to determine if dealership in request session has authorized
    # us. If they have save the authorization token to the dealership instance and
    # redirect the customer to the account details page.
    #
    def get(req)
      # TODO: Make sure a session exists and is a dealership id
      dealership = session_user(req)
      session = get_session(req)
      # TODO: Check session exists and is valid
      token = ::Ebay::Api.token(session)
      # TODO: Check `token` is valid
      @account = Lynr::Model::EbayAccount.new(
        'expires' => token.expires, 'token' => token.id, 'session' => session.id,
      )
      dealer_dao.save(dealership.set({ 'accounts' => Lynr::Model::Accounts.new([@account]) }))
      redirect "/admin/#{dealership.slug}/account?eBay_connect=success"
    end

    private

    # ## `Ebay::Callback#get_session(req)`
    #
    # Get the `Ebay::Session` out of the cache.
    #
    def get_session(req)
      session_data = Lynr::Cache.mongo.get("#{req.session['dealer_id']}_ebay_session")
      YAML.load(session_data)
    end

  end

end
