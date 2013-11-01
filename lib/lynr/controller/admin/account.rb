require 'json'

require 'lynr'
require 'lynr/controller/admin'
require 'lynr/queue/email_job'
require 'lynr/queue/stripe_update_job'

module Lynr; module Controller;

  class AdminAccount < Lynr::Controller::Admin

    get  '/admin/:slug/account', :get_account
    post '/admin/:slug/account', :post_account

    def before_each(req)
      return unauthorized unless authorized?(req)
      @dealership = dealer_dao.get(BSON::ObjectId.from_string(req['slug']))
    end

    def get_account(req)
      @subsection = 'account'
      @title = "Account Information"
      @transloadit_params = transloadit_params('account_template_id').to_json
      render 'admin/account.erb'
    end

    def post_account(req)
      @posted = req.POST
      @errors = validate_account_info
      if email_changed?
        notify_by_email
        @posted['identity'] = Lynr::Model::Identity.new(posted['email'], @dealership.identity.password)
      end
      @posted['image'] = translate_image
      dealership = dealer_dao.save(@dealership.set(posted))
      update_stripe(dealership) if email_changed? || name_changed?
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

    def notify_by_email
      Lynr.producer('email').publish(Lynr::Queue::EmailJob.new('email_updated', {
        to: @dealership.identity.email,
        subject: "Lynr.co email changed"
      }))
    end

    # ## Translate to image model
    def translate_image
      if !posted['image'].nil? && !posted['image'].empty?
        json = JSON.parse(posted['image'])
        Lynr::Model::SizedImage.inflate(json)
      else
        @dealership.image
      end
    end

    # ## Stripe Helper
    def update_stripe(dealership)
      Lynr.producer('stripe').publish(Lynr::Queue::StripeUpdateJob.new(dealership))
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
