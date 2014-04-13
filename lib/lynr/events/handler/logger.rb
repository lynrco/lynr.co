require 'yajl/json_gem'
require './lib/lynr/events/handler'

module Lynr

  # # `Lynr::Events::Handler::Logger`
  #
  # Handler to log an event. Used mostly for testing events are being
  # emitted and received appropriately.
  #
  class Events::Handler::Logger < Lynr::Events::Handler

    # ## `Events::Handler::Logger#call(event)`
    #
    # Log the contents of `event` to verify it is coming through as
    # expected.
    #
    def call(event)
      log.debug("type=event.handler event=#{JSON.pretty_generate(event)}")
    end

  end

end
