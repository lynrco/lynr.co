require './lib/sly'
require 'rack'

module Lynr; module Controller;

  class Auth < Sly::Node

    include Lynr::Logging

    get '/signup', :get_signup

    def get_signup(req)
    end

  end

end
