module Rack; module Middleware;

  # # `Rack::Middleware::Logger`
  #
  # Book keeping middleware to log a request happened and the status of the response.
  #
  class Logger

    # ## `Rack::Middleware::Logger.new(app, log)
    #
    # Middleware compatible constructor which accepts the downstream app to invoke.
    # `Logger` constructor also accepts `log` which is instance where request/response
    # information will be logged.
    #
    def initialize(app, log)
      @app = app
      @log = log
    end

    # ## `Rack::Middleware::Logger#call(env)`
    #
    # Standard Rack application method to invoke when running. Logs a message when
    # a request comes in and another message after a responses is returned from the
    # downstream application.
    #
    def call(env)
      path = env['PATH_INFO']
      @log.info("type=request path=#{path}")
      status, headers, @response = @app.call(env)
      @log.info("type=response path=#{path} status=#{status}")
      [status, headers, self]
    end

    # ## `Rack::Middleware::Logger#each(&block)`
    #
    # Standard Rack response iterator.
    #
    def each(&block)
      @response.each(&block)
    end

  end

end; end;
