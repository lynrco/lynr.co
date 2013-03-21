require 'rack'

require './lib/sly'
require './lib/sly/view/erb_helpers'

module Lynr; module Controller;

  class Auth < Sly::Node

    include Lynr::Logging
    # Provides `render` and `render_partial` methods
    include Sly::View::ErbHelpers

    def initialize
      super
      @headers = { "Content-Type" => "text/html; charset=utf-8" }
      @section = "auth"
    end

    get  '/signup', :get_signup
    post '/signup', :post_signup

    def get_signup(req)
      @subsection = "signup"
      @posted = {}
      render 'auth/signup', :layout => 'default_sly'
    end

    def post_signup(req)
      @subsection = "signup submitted"
      @posted = {}
      render 'auth/signup', :layout => 'default_sly'
    end

  end

end; end;
