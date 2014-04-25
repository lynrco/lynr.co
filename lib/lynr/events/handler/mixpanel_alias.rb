require 'mixpanel-ruby'

require './lib/lynr/events/handler'

module Lynr

  class Events::Handler::MixpanelAlias < Lynr::Events::Handler

    include Lynr::Events::Handler::WithDealership

    # ## `Events::Handler::MixpanelAlias#call(event)`
    #
    # Process `event` by aliasing distinct_id to dealership_id, both
    # pieces of information will be extracted from `event`.
    #
    def call(event)
      if distinct_id(event) && dealership_id(event)
        tracker.alias(dealership_id(event), distinct_id(event))
        tracker.people.set(dealership_id(event), {
          '$email' => dealership(event).identity.email,
        })
      end
      success
    rescue Mixpanel::ConnectionError => err
      log.warn("type=handler.failure id=#{id} message=#{err.message}")
      failure
    end

    # ## `Events::Handler::MixpanelAlias#distinct_id(event)`
    #
    # Extract the distinct_id from the data provided to `event` if one
    # exists.
    #
    def distinct_id(event)
      cookies = event[:cookies]
      mp, cookie = cookies.find { |key, data|
        key.to_s.start_with?('mp_') && key.to_s.end_with?('_mixpanel')
      }
      mp && JSON.parse(cookie)['distinct_id']
    end

    # ## `Events::Handler::MixpanelAlias#id`
    #
    # Identifier for a configured `MixpanelAlias` handler. The handler
    # `#id` does *not* vary by the data provided when the handler is
    # created.
    #
    def id
      "Handler::MixpanelAlias"
    end

    # ## `Events::Handler::MixpanelAlias#tracker`
    #
    # Create a `Mixpanel::Tracker` from the token provided in `data`.
    #
    def tracker
      @_tracker ||= Mixpanel::Tracker.new(config['token'])
    end

  end

end
