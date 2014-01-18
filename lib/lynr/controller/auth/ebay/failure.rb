require './lib/lynr/controller/admin'
require './lib/lynr/controller/auth/ebay'

module Lynr::Controller

  # # `Lynr::Controller::Ebay::Failure`
  #
  # Resource/Controller class to handle the case where authentication with eBay
  # fails for some reason.
  #
  class Ebay::Failure < Lynr::Controller::Admin

    include Lynr::Controller::Ebay::Helpers

    get  '/auth/ebay/failure', :get

    # ## `Ebay::Failure#get(req)`
    #
    # Clear the `::Ebay::Session` and send the customer back to the account screen
    # with a failure notice.
    #
    def get(req)
      dealership = session_user(req)
      # Remove the `Ebay::Session` from the cache
      clear_ebay_session(req)
      redirect "/admin/#{dealership.slug}/account?#{Ebay::Helpers::PARAM}=failure"
    end

  end

end
