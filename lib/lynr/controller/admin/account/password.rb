require './lib/lynr'
require './lib/lynr/controller/admin'
require './lib/lynr/validator'

module Lynr::Controller

  # # `Lynr::Controller::AdminAccountPassword`
  #
  # Controller for handling requests to change a password.
  #
  class AdminAccountPassword < Lynr::Controller::Admin

    include Lynr::Controller::FormHelpers
    include Lynr::Validator::Password

    get  '/admin/:slug/account/password', :get
    post '/admin/:slug/account/password', :post

    # ## `AdminAccountPassword.new`
    #
    # Setup shared instance variables
    #
    def intialize
      @subsection = 'account account-password'
      @title = "Change Password"
    end

    # ## `AdminAccountPassword#get(req)`
    #
    # Process GET for the `req` to get the password reset page
    #
    def get(req)
      render 'admin/account/password.erb'
    end

    # ## `AdminAccountPassword#post(req)`
    #
    # Process POST for the `req` to reset the account's password
    #
    def post(req)
      @errors = validate_change_password(@posted)
      render 'admin/account/password.erb' if has_errors?
      dealer = dealership(req).set({
        'identity' => Lynr::Model::Identity.new(dealership(req).identity.email, posted['password'])
      })
      dealer_dao.save(dealer)
      redirect "/admin/#{dealer.slug}/account?#{Helpers::PARAM}=success"
    end

    # ## `AdminAccountPassword#validate_change_password(posted)`
    #
    # Check the data in `posted` is valid for the reset request. Return a `Hash`
    # containing key => value pairs where key is field name and value is error
    # message.
    #
    def validate_change_password(posted)
      password = posted['password']
      confirm = posted['password']
      errors = validate_required(posted, ['password'])
      errors['password'] ||= error_for_passwords(password, confirm)
      errors.delete_if { |k,v| v.nil? }
    end

    # # `AdminAccountPassword::Helpers`
    #
    # Helper methods for password change controller.
    #
    module Helpers

      PARAM = 'pw'

      # ## `AdminAccountPassword::Helpers.connect_message(req)`
      #
      # Translate the value of `Helpers::PARAM` from `req` into a message that
      # can be displayed to the user.
      #
      def self.connect_message(req)
        case req.params[PARAM]
        when 'success' then 'Successfully changed your password.'
        end
      end

    end

  end

end
