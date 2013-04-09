require './lib/sly'
require './lib/sly/view/erb_helpers'

module Lynr; module Controller;

  class Base < Sly::Node

    include Lynr::Logging
    # Provides `render` and `render_partial` methods
    include Sly::View::ErbHelpers

    set_render_options({ layout: 'default_sly.erb' })

    def initialize
      super
      @headers = {
        "Content-Type" => "text/html; charset=utf-8",
        "Server" => "Lynr.co Application Server"
      }
    end

    def not_found
      render 'fourohfour.erb', status: 404
    end

  end

end; end;
