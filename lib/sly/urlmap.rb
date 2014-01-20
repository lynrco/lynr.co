require 'rack'

module Sly

  # # `Sly::URLMap`
  #
  # Modifies the base `Rack::URLMap` such that if another Rack app is added for a
  # location which is already mapped both apps are put into a `Rack::Cascade` and
  # the `Rack::Cascade` instances is provided for the location.
  #
  # See https://github.com/Ramaze/innate/blob/master/lib/innate/dynamap.rb
  # which extends http://rack.rubyforge.org/doc/Rack/URLMap.html for more information
  # because almost everything in this class is taken from it, save for the `URLMap#map`
  # method.
  #
  class URLMap < Rack::URLMap

    def initialize(map = {})
      @originals = map
      super
    end

    def at(location)
      @originals[location]
    end

    def call(env)
      raise "Nothing mapped yet" if @originals.empty?
      super
    end

    def delete(location)
      @originals.delete(location)
      remap(@originals)
    end

    # ## `Sly::URLMap#map(location, object)`
    #
    # If a Rack app already exists for `location` wrap the existing app in a new
    # `Rack::Cascade` instance, add `object` to the new `Rack::Cascade` and send
    # the `Cascade` to the parent class for `location`. If no app exists for `location`
    # pass along both `location` and `object` to the parent class' implementation.
    #
    def map(location, object)
      return unless location and object
      if (@originals.has_key? location)
        # Get the existing Rack application
        app = @originals[location]
        # If it isn't a Cascade make it one
        app = Rack::Cascade.new([app]) unless app.is_a? Rack::Cascade
        # Add the one we should be adding
        app.add(object)
        remap(@originals.merge(location.to_s => app))
      else
        remap(@originals.merge(location.to_s => object))
      end
    end

    # super may raise when given invalid locations, so we only replace the
    # `@originals` if we are sure the new map is valid
    def remap(map)
      value = super
      @originals = map
      value
    end

    def to(object)
      @originals.invert[object]
    end

    def to_hash
      @originals.dup
    end

  end

end
