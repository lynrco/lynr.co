require './lib/sly'
require 'rack'

module Lynr; module Controller;

  class Test < Sly::Node

    include Lynr::Logging

    # Order of route mapping matters because they are hit in order.
    # So the most general one must be specified last
    get '/car/:id', :vehicle2
    get '/car', :vehicle
    get '/test', :index

    def index(req)
      Rack::Response.new(["hi"], 200, { "Content-Type" => "text/plain" }).finish
    end

    def vehicle(req)
      log.info({ path_info: req.path })
      Rack::Response.new(["hi car"], 200, { "Content-Type" => "text/plain" }).finish
    end

    def vehicle2(req)
      log.info({ path_info: req.path })
      Rack::Response.new(["hi car2"], 200, { "Content-Type" => "text/plain" }).finish
    end

  end

end; end;
