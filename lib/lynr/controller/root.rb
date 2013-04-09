require './lib/lynr/controller/base'

module Lynr; module Controller;

  # # `Lynr::Controller::Root`
  #
  # `Root` is the catch all controller. It will handle everything
  # not mapped elsewhere in the project.
  class Root < Ramaze::Controller

    include Lynr::Logging

    map '/'

    layout :default

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

    # ## `Lynr::Controller::Root#index`
    #
    # Homepage. Automagically renders `views/index.erb` based on the method name
    # servicing the request, in this case `index`
    def index
      @title = "Welcome to Lynr.co"
      @section = "home"
    end

    def fourohfour
    end

    def fivehundy
    end

  end

end; end;
