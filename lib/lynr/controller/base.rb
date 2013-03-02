require 'ramaze'

module Lynr; module Controller;

  class Base < Ramaze::Controller

    include Lynr::Logging

    engine :erb

    # Executed after each `Innate::Action`. Every render_* method creates an
    # `Innate::Action`. So don't do anything complex in here.
    after_all do
      response['Server'] = 'Lynr.co Application Server'
    end

    def self.action_missing(path)
      return if path == '/fourohfour'
      try_resolve('/fourohfour')
    end

    def not_found
      response.status = 404
      action.layout = [:layout, "#{options.roots[0]}/#{options.layouts[0]}/default.erb"]
      action.view = "#{options.roots[0]}/#{options.views[0]}/fourohfour.erb"
    end

  end

end; end;
