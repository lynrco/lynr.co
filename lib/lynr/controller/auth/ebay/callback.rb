require './lib/ebay'
require './lib/lynr/controller/admin'
require './lib/lynr/controller/auth/ebay'
require './lib/lynr/model/accounts'
require './lib/lynr/model/ebay_account'

module Lynr::Controller

  # # `Lynr::Controller::Ebay::Callback`
  #
  # Resource/Controller class to handle the case where authentication with eBay
  # succeeds.
  #
  class Ebay::Callback < Lynr::Controller::Admin

    include Lynr::Controller::Ebay::Helpers

    get  '/auth/ebay/callback', :get

    # ## `Ebay::Callback#get(req)`
    #
    # Process `req` to determine if dealership in request session has authorized
    # us. If they have save the authorization token to the dealership instance and
    # redirect the customer to the account details page.
    #
    def get(req)
      dealership = session_user(req)
      # Make sure a session exists and is valid dealership
      return unauthorized if dealership.nil?
      result = "success"
      session = get_ebay_session(req)
      # If `session` doesn't exist or is invalid then we get an invalid `token`
      token = ::Ebay::Api.token(session)
      if token.valid?
        save_account(dealership, session, token)
      else
        result = "token_invalid"
      end
      redirect "/admin/#{dealership.slug}/account?#{Ebay::Helpers::PARAM}=#{result}"
    end

    protected

    # ## `Ebay::Callback#save_account(dealership, session, token)`
    #
    # Creates a `Lynr::Model::EbayAccount` from `session` and `token` and saves the
    # `EbayAccount` to `dealership`.
    #
    def save_account(dealership, session, token)
      account = Lynr::Model::EbayAccount.new(
        'expires' => token.expires, 'token' => token.id, 'session' => session.id,
      )
      # TODO: push token onto existing Accounts
      dealer_dao.save(dealership.set({ 'accounts' => Lynr::Model::Accounts.new([account]) }))
    end

  end

end
