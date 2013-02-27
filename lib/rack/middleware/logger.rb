require 'yajl/json_gem'

module Rack; module Middleware;

  class Logger

    def initialize(app, log)
      @app = app
      @log = log
    end

    def call(env)
      path = env['PATH_INFO']
      @log.info({ type: 'request', path: path })
      status, headers, @response = @app.call(env)
      @log.info({ type: 'response', path: path, status: status })
      [status, headers, self]
    end

    def each(&block)
      @response.each(&block)
    end

  end

end; end;
