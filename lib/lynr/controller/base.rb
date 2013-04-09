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
      response.status = 404
      action.layout = [:layout, "#{options.roots[0]}/#{options.layouts[0]}/default.erb"]
      action.view = "#{options.roots[0]}/#{options.views[0]}/fourohfour.erb"
    end

  end

end; end;
