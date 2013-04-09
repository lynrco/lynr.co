require 'rack'

module Sly

  # # `Sly::Request`
  #
  # Inherits from `Rack::Request` to add a little path param sugar on top.
  #
  class Request < Rack::Request

    # ## `Sly::Request#initialize`
    #
    # Call `Rack::Request#initialize` then calculate path parameters based on
    # the given path_regex.
    #
    # ### Params
    #
    # * `env` is the Rack environment Hash
    # * `path_regex` represents how to extract the path parameters associated
    #   with the `Sly::Route` currently being processed/handled.
    #
    def initialize(env, path_regex)
      super(env)
      path_data = path_regex.match(path)
      @path_params = Hash[path_data.names.map { |name| [name, path_data[name]] }] unless path_data.nil?
    end

    # ## `Sly::Request#params`
    #
    # Augments the `Rack::Request` params Hash with the data in the
    # path params.
    #
    # ### Returns
    #
    # A `Hash` containing all the GET, POST and path parameters.
    #
    def params
      @params ||= super.merge(@path_params)
    end

  end

end
