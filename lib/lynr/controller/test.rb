require './lib/sly'
require 'rack'

module Lynr; module Controller;

  class Test < Sly::Node

    include Lynr::Logging

    get '/test', :index
    def index(req)
      Rack::Response.new(["hi"], 200, { "Content-Type" => "text/plain" }).finish
    end

    get '/car', :vehicle
    def vehicle(req)
      log.info({ path_info: req.path })
      Rack::Response.new(["hi car"], 200, { "Content-Type" => "text/plain" }).finish
    end

  end

end; end;
