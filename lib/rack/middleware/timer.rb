require 'date'

module Rack; module Middleware;

  # # `Rack::Middleware::Timer`
  #
  # `Timer` is Rack Middleware to log data about how Rack takes to process requests.
  #
  class Timer

    # ## `Rack::Middleware::Timer.new(app, log)
    #
    # Middleware compatible constructor which accepts the downstream app to invoke.
    # `Timer` constructor also accepts `log` which is instance where response time
    # information will be logged.
    #
    def initialize(app, log)
      @app = app
      @log = log
    end

    # ## `Rack::Middleware::Timer#call(env)`
    #
    # Standard Rack application method to invoke when running. Tracks the request
    # start time before passing the request downstream and stop time, the time
    # after a responses is returned from downstream. The difference between stop and
    # start is computted and then logged.
    #
    def call(env)
      start = Time.now
      status, headers, @response = @app.call(env)
      stop = Time.now
      elapsed_ms = (stop - start) * 1000
      @log.debug("type=measure.response.elapsed \
method=#{env['REQUEST_METHOD']} \
path=#{env['PATH_INFO']} \
status=#{status} \
elapsed=#{elapsed_ms}ms")
      headers['x-response-time'] = "#{elapsed_ms}ms" if !headers.include? 'x-response-time'
      [status, headers, self]
    end

    # ## `Rack::Middleware::Timer#each(&block)`
    #
    # Standard Rack response iterator.
    #
    def each(&block)
      @response.each(&block)
    end

  end

end; end;
