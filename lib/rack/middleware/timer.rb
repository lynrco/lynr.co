require 'date'

module Rack; module Middleware;

  class Timer

    def initialize(app, log)
      @app = app
      @log = log
    end

    def call(env)
      start = Time.now
      status, headers, @response = @app.call(env)
      stop = Time.now
      elapsed_ms = (stop - start) * 1000
      @log.info("type=measure.response.elapsed method=#{env['REQUEST_METHOD']} path=#{env['PATH_INFO']} status=#{status} elapsed=#{elapsed_ms}ms")
      headers['x-response-time'] = "#{elapsed_ms}ms" if !headers.include? 'x-response-time'
      [status, headers, self]
    end

    def each(&block)
      @response.each(&block)
    end

  end

end; end;
