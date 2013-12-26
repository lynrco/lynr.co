require 'json'
require 'rest-client'

require './lib/lynr/controller/base'
require './lib/lynr/controller/form_helpers'
require './lib/lynr/validator/helpers'

module Lynr; module Controller;

  class Home < Lynr::Controller::Base

    # Provides `is_valid_email?`, `is_valid_password?`, `validate_required`
    include Lynr::Validator::Helpers
    # Provides `error_class`, `error_message`, `has_error?`, `has_errors?`,
    # `posted`, `card_data`
    include Lynr::Controller::FormHelpers

    get  '/', :index
    post '/', :launch_signup

    def initialize
      super
      @section = 'home'
      @title = 'Lynr.co'
    end

    def before_POST(req)
      @posted = req.POST.dup
    end

    def index(req)
      log.info('type=measure.render template=index.erb')
      render 'index.erb', layout: 'marketing/default.erb'
    end

    def launch_signup(req)
      log.info('type=measure.render template=index.erb')
      email = posted.fetch('email', '')

      @errors = validate(posted)
      @errors = add_list_member(posted) if !has_errors?

      if (has_error?('400') && @errors['400'].index("Address already exists") == 0)
        @errors.delete('400')
        @msg = "You're already signed up to be notified at '#{email}'."
      elsif !has_errors?
        @msg = "We'll send you an email to '#{email}' when we're ready for you."
      end

      log.debug("type=log.subscribe.launch msg=#{@msg} errors=#{@errors}")

      render 'index.erb', layout: 'marketing/default.erb'
    end

    private

    def add_list_member(posted)
      errors = {}
      config = Lynr.config('app').mailgun
      request_info = "type=log.rest.post url=#{url} data=#{data}"
      url = mail_list_url(config['key'], config['url'], config['domain'])
      data = {
        subscribed: true,
        address: posted.fetch('email', ''),
        name: posted.fetch('name', ''),
        vars: JSON.generate({ dealer_name: posted.fetch('dealer_name', '') })
      }
      response = RestClient.post(url, data)
      log.debug("#{request_info} response=#{JSON.parse(response)} status=#{response.code}")
      errors
    rescue RestClient::Exception => e
      response = JSON.parse(e.response)
      log.debug("#{request_info} response=#{response} status=#{e.http_code}")
      { e.http_code.to_s => response['message'] }
    end

    def validate(posted)
      errors = validate_required(posted, ['email'])
      email = posted.fetch('email', '')
      errors['email'] = "You must enter a valid email address." if !is_valid_email?(email)
      errors
    end

    def mail_list_url(key, url, domain)
      "https://api:#{key}@#{url}/lists/launch-notify@#{domain}/members"
    end

  end

end; end;
