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
      # TODO: Make sure a session exists and is a dealership id
      dealership = session_user(req)
      session = get_ebay_session(req)
      # TODO: Check session exists and is valid
      token = ::Ebay::Api.token(session)
      # TODO: Check `token` is valid
      @account = Lynr::Model::EbayAccount.new(
        'expires' => token.expires, 'token' => token.id, 'session' => session.id,
      )
      dealer_dao.save(dealership.set({ 'accounts' => Lynr::Model::Accounts.new([@account]) }))
      redirect "/admin/#{dealership.slug}/account?eBay_connect=success"
    end

  end

end
