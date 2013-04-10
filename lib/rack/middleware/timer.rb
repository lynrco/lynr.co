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
      @log.info({ type: 'data', method: env['REQUEST_METHOD'], path: env['PATH_INFO'], status: status, elapsed: "#{(stop - start) * 1000} ms" })
      headers['x-response-time'] = "#{stop - start} ms" if !headers.include? 'x-response-time'
      [status, headers, self]
    end

    def each(&block)
      @response.each(&block)
    end

  end

end; end;
