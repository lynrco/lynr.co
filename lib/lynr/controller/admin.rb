require 'json'
require 'openssl'

require './lib/lynr/controller'
require './lib/lynr/controller/form_helpers'
require './lib/lynr/converter/number_translator'
require './lib/lynr/persist/dealership_dao'
require './lib/lynr/persist/vehicle_dao'
require './lib/lynr/validator/helpers'
require './lib/lynr/view/menu'

module Lynr::Controller

  # # `Lynr::Controller::Admin`
  #
  # `Admin` is the catch all controller for admin pages. It will handle
  # everything under '/admin' not mapped elsewhere.
  #
  class Admin < Lynr::Controller::Base

    include Lynr::Controller::Authentication
    include Lynr::Controller::Authorization
    include Lynr::Controller::FormHelpers
    include Lynr::Validator::Helpers

    attr_reader :vehicle_dao

    def initialize
      super
      @section = "admin"
      @vehicle_dao = Lynr::Persist::VehicleDao.new
    end

    # ## `Admin#before_each(req)`
    #
    # Make sure the dealership associated with `:slug` exists, there
    # is an authenticated user and `#session_user` is authorized to view
    # the admin page associated with the dealerhsip in the request.
    #
    # NOTE: `super` is called at the end of this method in order to ensure
    # `Rack::Response` instances returned by child implementations of
    # `before_METHOD` methods are returned to user agent.
    #
    def before_each(req)
      if dealership(req).nil? then not_found
      elsif !authenticated?(req) then unauthenticated
      elsif !authorized?(role(req), session_user(req)) then unauthorized
      else super
      end
    end

    # ## Helpers

    # ## `Admin#dealership(req)`
    #
    # Get dealership object out of `req`.
    #
    def dealership(req)
      @dealership ||=
        if BSON::ObjectId.legal?(req['slug'])
          dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
        else
          dealer_dao.get_by_slug(req['slug'])
        end
    end

    # ## `Admin#role(req)`
    #
    # Define the role required to access this resource. This method is
    # meant to be overridden by child controllers.
    #
    def role(req)
      "admin:#{dealership(req).id}"
    end

    # ## `Admin#vehicle_count(req)`
    #
    # Get the number of vehicles for the current dealership.
    #
    def vehicle_count(req)
      @vehicle_count ||= vehicle_dao.count(dealership(req))
    end

    # ## Menus

    # ## `Admin#menu_primary`
    #
    # Overrides `Lynr::Controller::Base#menu_primary` to return a menu for the dealership.
    #
    def menu_primary
      Lynr::View::Menu.new('Menu', "/menu/#{@dealership.slug}", :menu_admin) unless @dealership.nil?
    end

    # ## `Admin#save_vehicle(vehicle)`
    #
    # Handle the logic of saving a `Lynr::Model::Vehicle` to the database
    # and producing the associated events.
    #
    def save_vehicle(vehicle)
      vehicle_dao.save(vehicle).tap do |saved|
        Lynr.producer('job').publish(Lynr::Queue::IndexVehicleJob.new(saved))
      end
    end

    # ## `Admin#transloadit_params(template_id_name)`
    #
    # Internal: Get a `Hash` of parameters for inclusion in an HTML
    # form element rendered to the customer.
    #
    # template_id_name - name of the [Transloadit](http://transloadit.com)
    #                    template id name in the app configuration
    #
    # Examples
    #
    #   # Controller
    #   @params = transloadit_params('account_template_id').to_json
    #   # HTML Template
    #   <form>
    #     <input type="hidden" name="params" value="<%= CGI.escape_html(@params) %>" />
    #   </form>
    #
    # Returns `Hash` with :auth and :template_id values for use with HTML
    # posting media to transloadit.
    #
    def transloadit_params(template_id_name)
      transloadit = Lynr.config('app')['transloadit']
      expires = (Time.now + (60 * 10)).utc.strftime('%Y/%m/%d %H:%M:%S+00:00')
      {
        auth: { expires: expires, key: transloadit['auth_key'] },
        template_id: transloadit[template_id_name]
      }
    end

    # ## `Admin#transloadit_params_signature(params)`
    #
    # Internal: Generate a signature from `params` to ensure transloadit
    # credentials are being used by an authorized account. This is necessary
    # when 'Enable signature authentication' is on inside the [Transloadit
    # API Credentials](https://transloadit.com/accounts/credentials)
    #
    # params - `Hash` of params from `Admin#transloadit_params` based on
    #          an `'auth_secret'` key in app configuration.
    #
    # Examples
    #
    #     # Controller
    #     params = transloadit_params('account_template_id')
    #     @signature = transloadit_params_signature(params)
    #     # HTML Template
    #     <form>
    #       <input type="hidden" name="signature" value="<%= @signature %>" />
    #     </form>
    #
    # Returns signature value to be sent alongside JSON representation of
    # parameters to authenticate the parameters.
    #
    def transloadit_params_signature(params)
      auth_secret = Lynr.config('app')['transloadit']['auth_secret']
      return nil if auth_secret.nil?
      digest = OpenSSL::Digest::Digest.new('sha1')
      OpenSSL::HMAC.hexdigest(digest, auth_secret, JSON.generate(params))
    end

  end

end
