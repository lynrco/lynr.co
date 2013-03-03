require './lib/sly'
require 'rack'

class Test < Sly::Node

  map('/test', :index)
  def index(req)
    Rack::Response.new(["hi"], 200, { "Content-Type" => "text/plain" }).finish
  end

end
