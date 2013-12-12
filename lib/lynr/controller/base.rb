require './lib/sly'
require './lib/sly/view/erb_helpers'

require './lib/lynr/logging'

module Lynr; module Controller;

  class Base < Sly::Node

    include Lynr::Logging
    # Provides `render` and `render_partial` methods
    include Sly::View::ErbHelpers

    set_render_options({ layout: 'default.erb' })

    # ## `Lynr::Controller::Base.create_route`
    #
    # Creates a `Sly::Route` with a `lambda` which enables pre-processing of
    # requests through `before_each` and `before_#{req.request_method}` methods
    # prior to execution of primary controller methods. If `before_each` returns
    # a `Rack::Response` instance then the primary controller will not be called,
    # the `Rack::Response` from `before_each` will be used instead
    #
    # ### Params
    #
    # See: `Sly::Node.create_route`
    #
    # ### Returns
    #
    # See: `Sly::Node.create_route`
    #
    def self.create_route(path, method_name, verb)
      method = method_name.to_sym
      Sly::Route.new(verb, path, lambda { |req|
        controller = self.new
        response = controller.before_each(req)
        response = controller.send(method, req) if !response.is_a?(Rack::Response)
        response
      })
    end

    def initialize
      super
      @headers = {
        "Content-Type" => "text/html; charset=utf-8",
        "Server" => "Lynr.co Application Server"
      }
    end

    # BEFORE HANDLING

    # ## `Lynr::Controller::Base#before_each`
    #
    # Hand off processing to `before_#{req.request_method}` for GET or POST
    # requests.
    #
    # ### Params
    #
    # * `req` the `Sly::Request` to be (pre-)processed
    #
    # ### Returns
    #
    # Returns the result of `before_#{req.request_method}` or nil
    #
    def before_each(req)
      case req.request_method
        when 'GET'  then before_GET(req)
        when 'POST' then before_POST(req)
        else nil
      end
    end

    # ## `Lynr::Controller::Base#before_GET`
    #
    # Empty placeholder method for pre-processing of GET requests
    #
    # ### Params
    #
    # * `req` the `Sly::Request` to be (pre-)processed
    #
    # ### Returns
    #
    # nil
    #
    def before_GET(req)
    end

    # ## `Lynr::Controller::Base#before_POST`
    #
    # Empty placeholder method for pre-processing of POST requests
    #
    # ### Params
    #
    # * `req` the `Sly::Request` to be (pre-)processed
    #
    # ### Returns
    #
    # nil
    #
    def before_POST(req)
    end

    # ERROR RESPONSES

    def error(status=500)
      @status = status
      case status
      when 404
        render 'fourohfour.erb', status: 404
      else
        render 'fivehundy.erb', status: status
      end
    end

    def not_found
      error(404)
    end

    def unauthorized
      error(403)
    end

  end

end; end;
