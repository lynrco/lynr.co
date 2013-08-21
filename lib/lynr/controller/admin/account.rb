require 'json'
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
      @transloadit_params = {
        auth: { key: Lynr::App.config['transloadit']['auth_key'] },
        template_id: Lynr::App.config['transloadit']['account_template_id']
      }.to_json
      render 'admin/account.erb'
    end

    def post_account(req)
      return unauthorized unless authorized?(req)
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
      @posted = req.POST
      @errors = validate_account_info
      # TODO: These updates should be scheduled, they aren't critical
      update_stripe if email_changed? || name_changed?
      # TODO: Trigger an email warning about email change
      if email_changed?
        @posted['identity'] = Lynr::Model::Identity.new(posted['email'], @dealership.identity.password)
      end
      @posted['image'] = translate_image
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

    # ## Translate to image model
    def translate_image
      if !posted['image'].nil? && !posted['image'].empty?
        json = JSON.parse(posted['image'])
        Lynr::Model::Image.inflate(json)
      else
        @dealership.image
      end
    end

    # ## Stripe Helper
    def update_stripe
      customer = Stripe::Customer.retrieve(@dealership.customer_id)
      customer.description = posted['name'] if name_changed?
      customer.email = posted['email'] if email_changed?
      customer.save
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
