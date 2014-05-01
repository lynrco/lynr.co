require './lib/lynr/events/handler'
require './lib/lynr/queue/email_job'

module Lynr

  # # `Lynr::Events::Handler::Email`
  #
  # Handler to enqueue an `EmailJob` in response to an event.
  #
  class Events::Handler::Email < Lynr::Events::Handler

    include Lynr::Events::Handler::WithDealership

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

    # ## `Handler::Email#domain(event)`
    #
    # Internal: Get the domain to send to `Lynr::Queue::EmailJob`s
    # produced by this event handler. `domain` is dependent on
    # `event[:type]` and `Lynr.config('app').domain`. If domain from
    # application configuration. This method knows about the live and
    # staging environments/domains and no others.
    #
    # NOTE: This feels wrong. The application shouldn't have to make
    # inferences based on configuration values but I can't figure out a
    # cleaner way to get this bit of config from the event producer
    # (demo site) to the event processor (live site) without having an
    # event processor unique to each event producer. - BJS 2014-04-30
    #
    # * event - `Hash` of event data to be handled by this event handler.
    #
    # Returns String to be used as the base domain in the email template
    # when sent.
    #
    def domain(event)
      domain = Lynr.config('app').domain
      if event[:type].match(/\.demo\Z/)
        case domain
        when %r(stage\.herokuapp\.com$) then domain.gsub(/\.heroku/, '-demo.heroku')
        when %r(\Awww\.lynr\.co\Z) then domain.gsub(/www/, 'demo')
        else domain
        end
      else
        domain
      end
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
      {
        to: to(event),
        base_url: "https://#{domain(event)}",
        dealership: dealership(event),
        support_email: Lynr.config('app').support_email,
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
