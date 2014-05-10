require 'rack'

module Rack; module Middleware;

  # # `Rack::Middleware::Redirect`
  #
  # Public: Stupid rewrite rules implementation. Allows redirection to
  # happen # based on rules. Rules are defined as Ruby `Hash` instances
  # with # `:test` and `:target` keys where `:test` is expected to be a
  # regular expression and `:target` is used as the second argument to
  # `String#gsub` if `:test` matches the path.
  #
  # Examples:
  #
  #     use Rack::Middleware::Redirect [
  #         { test: %r(\A/Bryan_Swift\Z), target: '/bryan' },
  #       ]
  #
  class Redirect

    # ## `Redirect.new(app, rules)`
    #
    # Public: Create a new Redirect instance.
    #
    # * app   - Rack app to be called if we are not handling the request
    # * rules - `Array` of `Hash` instances with `:test` and `:target`
    #           keys
    #
    def initialize(app, rules)
      @app = app
      @rules = rules
    end

    # ## `Redirect#call(env)`
    #
    # Public: Process `env` as a Rack request to determine if the path
    # in `env` should be redirected according to one of `rules` provided
    # when creating this instance.
    #
    # * env - Rack environment
    #
    # Returns the response from the downstream Rack application or a
    # redirect response depending on whether `env['PATH_INFO']` matched
    # one of the `rules` provided.
    #
    def call(env)
      path = env['PATH_INFO']

      target = @rules.reduce(nil) do |result, rule|
        if result
          result
        elsif matched = rule[:test].match(path)
          path.gsub(rule[:test], rule[:target])
        end
      end

      if target.nil?
        @app.call(env)
      else
        if target.start_with?('//') then target = "http:#{target}" end
        response = Rack::Response.new
        response.redirect(target, 302)
        response.finish
      end
    end

  end

end; end;
