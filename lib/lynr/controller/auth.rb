require './lib/lynr/controller'
require './lib/lynr/controller/base'
require './lib/lynr/controller/form_helpers'
require './lib/lynr/persist/dealership_dao'
require './lib/lynr/validator'

module Lynr; module Controller;

  # # `Lynr::Controller::Auth`
  #
  # Controller for the authorization actions like creating an account or
  # signing into an existing account.
  #
  class Auth < Lynr::Controller::Base

    include Lynr::Controller::FormHelpers
    include Lynr::Validator::Email
    include Lynr::Validator::Helpers
    include Lynr::Validator::Password

    # ## `Lynr::Controller::Auth.new`
    #
    # Create a new Auth controller with default information like headers and
    # section information.
    #
    def initialize
      super
      @section = "auth"
    end

    # ## `Auth#before_GET(req)`
    #
    # Redirect to the admin page if there is already a dealer_id in the
    # session.
    #
    def before_GET(req)
      if !req.params['next'].nil? then req.session['next'] = req.params['next'] end
      if !req.session['dealer_id'].nil?
        send_to_next(req) || send_to_admin(req)
      else
        super
      end
    end

    def dealer_dao
      @dealer_dao ||= Lynr::Persist::DealershipDao.new
    end

    # ## `Auth#send_to_admin(req, dealership)`
    #
    # Redirect `req` to the inventory screen for `dealership`. If
    # `dealership` is `nil` then retrieve dealership from the session
    # attached to `req`.
    #
    def send_to_admin(req, dealership=nil)
      dealership = dealer_dao.get(req.session['dealer_id']) if dealership.nil?
      redirect "/admin/#{dealership.slug}"
    end

    # ## `Auth#send_to_next(req)`
    #
    # Redirect `req` to the URI stored in the session as 'next' if it
    # exists, otherwise return false.
    #
    def send_to_next(req)
      if !req.session['next'].nil?
        redirect req.session['next']
      else
        false
      end
    end

  end

end; end;

require './lib/lynr/controller/auth/forgot'
require './lib/lynr/controller/auth/signin'
require './lib/lynr/controller/auth/signup'
require './lib/lynr/controller/signout'
