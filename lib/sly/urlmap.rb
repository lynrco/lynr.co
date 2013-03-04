require 'rack'
require 'innate'

module Sly

  class URLMap < Innate::URLMap

    def map(location, object)
      return unless location and object
      if (@originals.has_key? location)
        # Get the existing Rack application
        app = @originals[location]
        # If it isn't a Cascade make it one
        app = Rack::Cascade.new([app]) unless app.is_a? Rack::Cascade
        # Add the one we should be adding
        app.add(object)
        super(location, app)
      else
        super(location, object)
      end
    end

  end

end
