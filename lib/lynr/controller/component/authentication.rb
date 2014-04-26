require './lib/lynr/controller'

module Lynr::Controller

  # # `Lynr::Controller::Authentication`
  #
  # Provide methods to determine the state of authentication, whether or
  # not a valid user exists. This helps decouple authentication from
  # authorization.
  #
  module Authentication

    # ## `Authentication#authenticated?(req)`
    #
    # Determine if there is an autheniticated user attached to `req`.
    # This check is done by assessing the 'dealer_id' property of the
    # session attached to `req`.
    #
    def authenticated?(req)
      !req.session['dealer_id'].nil?
    end

    # ## `Authentication#authenticates?(email, password)`
    #
    # Check if `email` and `password` successfully authenticate against
    # the identity determined by `email.
    #
    def authenticates?(email, password)
      account = dealer_dao.get_by_email(email)
      !account.nil? && !account.identity.nil? && account.identity.auth?(email, password)
    end

    # ## `Authentication#account_exists?(email)`
    #
    # Check if there is an identity associated with `email`.
    #
    def account_exists?(email)
      dealer_dao.account_exists?(email)
    end

  end

end
