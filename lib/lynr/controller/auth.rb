require './lib/sly'
require './lib/sly/view/erb_helpers'
require './lib/lynr/validator/helpers'
require './lib/lynr/persist/dealership_dao'

module Lynr; module Controller;

  class Auth < Sly::Node

    include Lynr::Logging
    # Provides `is_valid_email?`
    include Lynr::Validator::Helpers
    # Provides `render` and `render_partial` methods
    include Sly::View::ErbHelpers

    attr_reader :dao

    def initialize
      super
      @headers = {
        "Content-Type" => "text/html; charset=utf-8",
        "Header" => "Lynr.co Application Server"
      }
      @section = "auth"

      @dao = Lynr::Persist::DealershipDao.new
    end

    get  '/signup', :get_signup
    post '/signup', :post_signup
    get  '/signin', :get_signin

    set_render_options({ layout: 'default_sly.erb' })

    def get_signup(req)
      @subsection = "signup"
      @posted = {}
      @errors = {}
      @title = "Sign Up for Lynr"
      render 'auth/signup.erb'
    end

    def post_signup(req)
      @subsection = "signup submitted"
      @posted = req.POST
      @errors = validate_signup(@posted)
      if (@errors.empty?)
        # Create account
        identity = Lynr::Model::Identity.new(@posted['email'], @posted['password'])
        # Create Customer and subscribe them
        customer = Stripe::Customer.create(
          card: @posted['stripeToken'],
          plan: 'lynr_beta',
          email: identity.email
        )
        # Create and Save dealership
        dealership = Lynr::Model::Dealership.new({ 'identity' => identity, 'customer_id' => customer.id })
        @dealership = dao.save(dealership)
        # Send to admin pages?
        render 'auth/signed_up.erb'
      else
        render 'auth/signup.erb'
      end
    rescue Stripe::InvalidRequestError => sire
      log.warn { sire }
      @errors['stripeToken'] = "You might have submitted the form more than once."
      render 'auth/signup.erb'
    end

    def get_signin(req)
      @subsection = "signin"
      @posted = {}
      @title = "Sign In for Lynr"
      render 'auth/signin.erb'
    end

    def post_signin(req)
      @subsection = "signup submitted"
      @posted = req.POST
      @errors = validate_signin(@posted)
      if (@errors.empty?)
      else
        render 'auth/signin.erb'
      end
    end

    def validate_signup(posted)
      email = posted['email']
      password = posted['password']
      errors = {}

      if (!is_valid_email?(posted['email']))
        errors['email'] = "Check your email address."
      end
      if (!is_valid_password?(password))
        errors['password'] = "Your password is too short."
      end
      if (password != posted['password_confirm'])
        errors['password'] = "Your passwords don't match."
      end
      if (posted['agree_terms'].nil?)
        errors['agree_terms'] = "You must agree to Terms &amp; Conditions."
      end
      if (posted['stripeToken'].nil?)
        errors['stripeToken'] = "Your card wasn't accepted."
      end

      errors
    end

    def validate_signin(posted)
      errors = {}
      ['email', 'password'].each do |key|
        if (!(posted.include?(key) && posted[key].length > 0))
          errors[key] = 'Required'
        end
      end

      errors
    end

  end

end; end;
