require './lib/lynr/controller'
require './lib/lynr/controller/auth'
require './lib/lynr/events'
require './lib/lynr/model/dealership'
require './lib/lynr/persist/dao'

module Lynr::Controller

  # # `Lynr::Controller::Auth::Signin`
  #
  # Class to encapsulate the logic of displaying the singin page as well as
  # authenticating accounts.
  #
  class Auth::Signin < Lynr::Controller::Auth

    include Lynr::Controller::Authentication

    get  '/signin',        :get_signin
    post '/signin',        :post_signin
    get  '/signin/:token', :get_token_signin

    # ## `Auth::Signin.new`
    #
    # Create a new controller instance to allow for account authentication.
    #
    # NOTE: The behavior of the `Signin` varies based on the 'demo'
    # feature flag. When a new `Signin` instance is created either the
    # `Signin::Default` or `Signin::Demo` modules are used to extend the
    # controller. These modules provide the `#get_signin` and `#post_signin`
    # methods through which requests are routed in order to generate HTTP
    # responses.
    #
    def initialize
      super
      if Lynr.features.demo?
        self.send(:extend, Signin::Demo)
      end
    end

    # ## `Auth::Signin#before_each(req)`
    #
    # Set attributes used in all methods.
    #
    def before_each(req)
      @subsection = "signin"
      @title = "Sign In to Lynr"
      super
    end

    # ## `Auth::Signin#before_POST(req)`
    #
    # Perform validation and hand-off to `#get_signin` method if
    # there are errors to display.
    #
    def before_POST(req)
      super
      @errors = validate_signin(@posted)
      get_signin(req) if has_errors?
    end

    # ## `Auth::SignIn#get_signin(req)`
    #
    # Render `#template_path` for a GET request.
    #
    def get_signin(req)
      render template_path()
    end

    # ## `Auth::Signin#get_token_signin(req)`
    #
    # Handle authentication by token created when a customer issues a
    # forgotten password request.
    #
    def get_token_signin(req)
      id = BSON::ObjectId.from_string(req['token'])
      dao = Lynr::Persist::Dao.new
      token = dao.read(id)
      # TODO: There needs to be an error message if the token is expired
      return unauthorized if token.nil? or token.expired?
      dao.delete(id)
      req.session['dealer_id'] = token.dealership
      redirect "/admin/#{token.dealership.to_s}/account/password"
    end

    # ## `Auth::Signin#post_signin(req)`
    #
    # Handle the logic of signing a customer into the application. Sets
    # the session information and authentication details before forwarding
    # to the inventory.
    #
    def post_signin(req)
      dealership = dealer_dao.get_by_email(@posted['email'])
      Lynr::Events.emit(type: 'signin', dealership_id: dealership.id.to_s)
      # Send to admin pages
      req.session['dealer_id'] = dealership.id
      send_to_admin(req, dealership)
    end

    # ## `Auth::Signin#template_path()`
    #
    # Define the path for the template to be rendered for GET requests
    # and POST requests with errors.
    #
    def template_path()
      'auth/signin.erb'
    end

    # ## `Auth::Signin#validate_signin(posted)`
    #
    # Make sure credentials exist and authenticate successfully.
    #
    def validate_signin(posted)
      errors = validate_required(posted, ['email', 'password'])
      email = posted['email']
      password = posted['password']

      unless authenticates?(email, password)
        errors['account'] = "Unable to sign you in. Double check your email and password."
      end

      errors.delete_if { |k,v| v.nil? }
    end

    # # `Lynr::Controller::Auth::Signin::Demo`
    #
    # Method definitions to use when the demo 'feature' is on.
    #
    module Demo

      # ## `Auth::Signin::Demo#template_path()`
      #
      # Define the path for the template to be rendered for GET requests
      # and POST requests with errors.
      #
      def template_path()
        'demo/auth/signin.erb'
      end

      # ## `Auth::Signin::Demo#validate_signin(posted)`
      #
      # Make sure credentials exist and authenticate successfully.
      #
      def validate_signin(posted)
        errors = validate_required(posted, ['email'])
        email = posted['email']

        unless authenticates?(email, email)
          errors['account'] = <<ERR
An account exists for that email address but it has a password. Should you be on \
the <a href="https://#{Lynr.config('app').live_domain}/signin">Live Site</a>?
ERR
        end

        errors.delete_if { |k,v| v.nil? }
      end

    end

  end

end
