require './lib/lynr/events/handler'
require './lib/lynr/queue/email_job'

module Lynr

  # # `Lynr::Events::Handler::Email`
  #
  # Handler to enqueue an `EmailJob` in response to an event.
  #
  class Events::Handler::Email < Lynr::Events::Handler

    attr_reader :template

    # ## `Events::Handler::Email.new(config)`
    #
    # Create a new `Email` handler with `config`. `config` must contain
    # `:template` as it is provided to the `Lynr::Queue::EmailJob` this
    # handler creates.
    #
    def initialize(config={})
      @template = config.fetch(:template)
      super(config.delete(:template))
    end

    # ## `Events::Handler::Email#call(event)`
    #
    # Process `event` into an `EmailJob` and produce `EmailJob` to the
    # 'job' queue.
    #
    def call(event)
      mail_data = mail_defaults(event).merge(config.to_hash)
      Lynr.producer('job').publish(Lynr::Queue::EmailJob.new(template, mail_data))
      success
    end

    # ## `Events::Handler::Email#dealership(event)`
    #
    # Get a `Lynr::Model::Dealership` from the information provided in
    # `event`.
    #
    def dealership(event)
      dealership_dao.get(event[:dealership_id])
    end

    # ## `Events::Handler::Email#id`
    #
    # Identifier for a configured `Email` handler. The handler `#id`
    # varies by the template provided when the handler is created.
    #
    def id
      "Handler::Email(#{template})"
    end

    # ## `Events::Handler::Email#mail_defaults(event)`
    #
    # Get/create mail template properties from `event`.
    #
    def mail_defaults(event)
      app_config = Lynr.config('app')
      {
        to: to(event),
        base_url: "https://#{app_config.domain}",
        support_email: app_config.support_email,
      }
    end

    # ## `Events::Handler::Email#to(event)`
    #
    # Extract the email address to which the email in `EmailJob` will
    # be sent.
    #
    def to(event)
      event.fetch(:to, config.fetch(:to, dealership(event).identity.email))
    end

  end

end
