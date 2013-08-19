require 'lynr/controller/admin'

module Lynr; module Controller;

  class AdminAccount < Lynr::Controller::Admin

    get  '/admin/:slug/account', :get_account
    post '/admin/:slug/account', :post_account

    def get_account(req)
      return unauthorized unless authorized?(req)
      @subsection = 'account'
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @title = "Account Information"
      @transloadit_params = Lynr::App.config['transloadit'].to_json
      render 'admin/account.erb'
    end

    def post_account(req)
      return unauthorized unless authorized?(req)
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @posted = req.POST
      @errors = validate_account_info
      # TODO: These updates should be scheduled, they aren't critical
      if email_changed? || name_changed?
        customer = Stripe::Customer.retrieve(@dealership.customer_id)
        customer.description = posted['name'] if name_changed?
        customer.email = posted['email'] if email_changed?
        customer.save
      end
      # TODO: Trigger an email warning about email change
      if email_changed?
        @posted['identity'] = Lynr::Model::Identity.new(posted['email'], @dealership.identity.password)
      end
      if !@posted['image'].nil? && !@posted['image'].empty?
        json = JSON.parse(@posted['image'])
        @posted['image'] = Lynr::Model::Image.inflate(json)
      end
      @dealership = dealer_dao.save(@dealership.set(posted))
      redirect "/admin/#{@dealership.id.to_s}/account"
    end

    protected

    # ## Logic Helpers

    def email_changed?
      @dealership.identity.email != posted['email']
    end

    def name_changed?
      @dealership.name != posted['name']
    end

    # ## Data Validation

    def validate_account_info
      errors = validate_required(posted, ['email'])
      email = posted['email']

      if (errors['email'].nil?)
        if (!is_valid_email?(email))
          errors['email'] = "Check your email address."
        elsif (email != @dealership.identity.email && dealer_dao.account_exists?(email))
          errors['email'] = "#{email} is already taken."
        end
      end

      errors
    end

  end

end; end;
