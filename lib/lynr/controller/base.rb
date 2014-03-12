require './lib/sly'
require './lib/sly/view/erb_helpers'

require './lib/lynr/logging'

module Lynr; module Controller;

  # # `Lynr::Controller::Base`
  #
  # Defines the basic behavior for `Lynr::Controller` classes including helper
  # methods and simple implementations meant to be overriden. Most notably
  # `Controller::Base` overrides `Sly::Node.create_route` in order to augment
  # the default `Sly::Route` creation with some before handling. The
  # `#before_each(req)` method gets called before every request processed by
  # a `Sly::Route` created from `Controller::Base`. This allows things like
  # checking for an authenticated user to be separated out from each request
  # handler.
  #
  # `Controller::Base` also defines a baseline set of HTTP headers to be included
  # in every response.
  #
  class Base < Sly::Node

    include Lynr::Logging
    # Provides `render`, `render_partial` and `render_view` methods
    include Sly::View::ErbHelpers

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
        response = controller.send(method, req) unless response.is_a?(Rack::Response)
        response
      })
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
    # Placeholder method for pre-processing of POST requests that makes sure
    # `@posted` gets set.
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
      @posted = req.POST.dup
    end

    def dealer_dao
      return @dealer_dao unless @dealer_dao.nil?
      @dealer_dao = Lynr::Persist::DealershipDao.new
    end

    def headers
      Lynr.config('app').headers.to_hash
    end

    def render_options
      super.merge({ root: Lynr.root, layout: 'default.erb', layouts: 'layout' })
    end

    # MENUS

    # ## `Lynr::Controller::Base#menu_primary`
    #
    # Gets a refence to the primary menu
    #
    # ### Returns
    #
    # `Lynr::View::Menu` instance for primary menu if one exists, nil otherwise
    #
    def menu_primary
      nil
    end

    # ## `Lynr::Controller::Base#menu_secondary`
    #
    # Gets a refence to the primary menu
    #
    # ### Returns
    #
    # `Lynr::View::Menu` instance for secondary menu if one exists, nil otherwise
    #
    def menu_secondary
      nil
    end

    # ## `Lynr::Controller::Base#session_user`
    #
    # Gets the current user out of the session and returns it
    #
    # ### Params
    #
    # * `req` Request with access to session out of which to get the user
    #
    # ### Returns
    #
    # Currently logged in instance of `Lynr::Model::Dealership`
    #
    def session_user(req)
      id = req.session['dealer_id']
      dealer_dao.get(id)
    end

    def unauthorized
      error(403)
    end

  end

end; end;
