require './lib/lynr/model/token'
require './lib/lynr/persist/dao'

module Lynr::Controller

  class Auth::Forgot < Lynr::Controller::Auth

    get  '/signin/forgot',  :get_forgot
    post '/signin/forgot',  :post_forgot

    def get_forgot(req)
      @subsection = "forgot"
      @title = "Forgot Password"
      render 'auth/forgot.erb'
    end

    def post_forgot(req)
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

    def notify_by_email(dealership, token, req)
      Lynr.producer('email').publish(Lynr::Queue::EmailJob.new('auth/forgot', {
        to: dealership.identity.email,
        subject: "Lynr.co password reset",
        url: "#{req.base_url}/signin/#{token.id}",
        token_expires: token.expires,
      }))
    end

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
