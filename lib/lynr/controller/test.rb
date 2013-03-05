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
      Rack::Response.new(["hi"], 200, { "Content-Type" => "text/plain" })
    end

    def vehicle(req)
      @headers = { "Content-Type" => "text/plain" }
      render('index.erb')
    end

    def vehicle2(req)
      Rack::Response.new(["hi car2"], 200, { "Content-Type" => "text/plain" })
    end

  end

end; end;
