require 'sly'
require 'sly/view/erb_helpers'

require 'lynr/logging'

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

    def error(status=500)
      @status = status
      case status
      when 404
        render 'fourohfour.erb', status: 404
      else
        render 'fivehundy.erb', status: status
      end
    end

    def not_found
      error(404)
    end

    def unauthorized
      error(403)
    end

  end

end; end;
