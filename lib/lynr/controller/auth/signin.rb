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
      else
        self.send(:extend, Signin::Default)
      end
    end

    # ## `Auth::Signup#before_each(req)`
    #
    # Set attributes used in all methods.
    #
    def before_each(req)
      @subsection = "signin"
      @title = "Sign In to Lynr"
      super
    end

    def before_POST(req)
      super
      @errors = validate_signin(@posted)
      render 'auth/signin.erb' if has_errors?
    end

    def post_signin(req)
      dealership = dealer_dao.get_by_email(@posted['email'])
      Lynr::Events.emit(type: 'signin', dealership_id: dealership.id.to_s)
      # Send to admin pages
      req.session['dealer_id'] = dealership.id
      send_to_admin(req, dealership)
    end

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

    # # `Lynr::Controller::Auth::Signin::Default`
    #
    # Method definitions to use by default. These should be a part of
    # the class definition but if they are they can not be overridden by
    # including the `Demo` module.
    #
    # NOTE: With Ruby 2.0 `Demo` module could be included via `prepend`
    # which would allow class method definitions to be overriden.
    #
    module Default

      # ## Sign In Handlers
      def get_signin(req)
        render 'auth/signin.erb'
      end

      def validate_signin(posted)
        errors = validate_required(posted, ['email', 'password'])
        email = posted['email']
        password = posted['password']

        if (authenticates?(email, password))
          errors['account'] = "Invalid email or password."
        end

        errors.delete_if { |k,v| v.nil? }
      end

    end

    # # `Lynr::Controller::Auth::Signin::Demo`
    #
    # Method definitions to use when the demo 'feature' is on.
    #
    module Demo

      # ## Sign In Handlers
      def get_signin(req)
        render 'demo/auth/signin.erb'
      end

      def validate_signin(posted)
        errors = validate_required(posted, ['email'])
        email = posted['email']

        if (authenticates?(email, email))
          errors['account'] = "Invalid email."
        end

        errors.delete_if { |k,v| v.nil? }
      end

    end

  end

end
