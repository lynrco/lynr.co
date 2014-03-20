require './lib/lynr/model/token'
require './lib/lynr/persist/dao'

module Lynr::Controller

  # # `Lyrn::Controller::Auth::Forgot`
  #
  # Controller for the forgot password actions.
  #
  class Auth::Forgot < Lynr::Controller::Auth

    get  '/signin/forgot',  :get
    post '/signin/forgot',  :post

    # ## `Auth::Forgot#get(req)`
    #
    # Process GET `req` into the rendered HTML for showing the forgot
    # password page.
    #
    def get(req)
      @subsection = "forgot"
      @title = "Forgot Password"
      render 'auth/forgot.erb'
    end

    # ## `Auth::Forgot#get(req)`
    #
    # Process POST `req` into the rendered HTML for showing the forgot
    # password page in addition to performing the processing of creating a token
    # for simple authentication and sending an email about the token.
    #
    def post(req)
      @subsection = "forgot"
      @title = "Forgot Password"
      @errors = validate_forgot(@posted)
      return render 'auth/forgot.erb' if has_errors?
      dealership = dealer_dao.get_by_email(@posted['email'])
      dao = Lynr::Persist::Dao.new
      token = dao.create(Lynr::Model::Token.new('dealership' => dealership))
      notify_by_email(dealership, token, req)
      @msg = "Reset notification sent to #{@posted['email']}"
      render 'auth/forgot.erb'
    end

    protected

    # ## `Auth::Forgot#notifiy_by_email(dealership, token, req)`
    #
    # Send a notification email to the `Identity` associated with `dealership`
    # that password assistance has been requested.
    #
    def notify_by_email(dealership, token, req)
      Lynr.producer('job').publish(Lynr::Queue::EmailJob.new('auth/forgot', {
        to: dealership.identity.email,
        subject: "Lynr.co password reset",
        base_url: req.base_url,
        url: "#{req.base_url}/signin/#{token.id}",
        token_expires: token.expires,
      }))
    end

    # ## `Auth::Forgot#validate_forgot(posted)`
    #
    # Check the data in `posted` for validation errors, specifically looking
    # to make sure email is well formed and is tied to an existing user account.
    #
    def validate_forgot(posted)
      errors = validate_required(posted, ['email'])
      email = posted['email']

      errors['email'] ||=
        if !is_valid_email?(email)
          "#{email} doesn't look valid."
        elsif !dealer_dao.account_exists?(email)
          "No account for #{email}."
        end

      errors.delete_if { |k,v| v.nil? }
    end

  end

end
