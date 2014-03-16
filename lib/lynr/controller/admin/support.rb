require './lib/lynr'
require './lib/lynr/controller/admin'

module Lynr::Controller

  # # `Lynr::Controller::Admin::Support`
  #
  # Handle requests to the support pages.
  #
  class Admin::Support < Lynr::Controller::Admin

    get  '/admin/:slug/support', :get
    post '/admin/:slug/support', :post

    # ## `Admin::Support.new`
    #
    # Setup global attribute values.
    #
    def initialize
      super
      @title = "Lynr.co Support"
      @subsection = "support"
    end

    # ## `Admin::Support#before_POST(req)`
    #
    # Do validation and render if there are errors.
    #
    def before_POST(req)
      super
      @errors = validate(req)
      get(req) if has_errors?
    end

    # ## `Admin::Support#get(req)`
    #
    # Handle the GET method to the support resource.
    #
    def get(req)
      render 'admin/support.erb'
    end

    # ## `Admin::Support#post(req)`
    #
    # Handle the POST method to the support resource.
    #
    def post(req)
      send_email(req)
      @msg = "Your support request has been sent. Someone will be in touch shortly."
      render 'admin/support.erb'
    end

    # ## `Admin::Support#send_email(req)`
    #
    # Queue a message to be sent to the support email address based on
    # the information provided by the customer in the POST `req`.
    #
    def send_email(req)
      Lynr.producer('email').publish(Lynr::Queue::EmailJob.new('none', {
        from: 'Lynr Support Page <robot@mg.lynr.co>',
        to: 'support@lynr.co',
        subject: "[Support] #{posted['subject']}",
        'h:Reply-To' => dealership(req).identity.email,
        'v:dealership_id' => dealership(req).id.to_s,
        base_url: req.base_url,
        content: posted['body'],
      }))
    end

    # ## `Admin::Support#validate(req)`
    #
    # Validate the required fields in the `req`.
    #
    def validate(req)
      validate_required(posted, ['subject', 'body'])
    end

  end

end
