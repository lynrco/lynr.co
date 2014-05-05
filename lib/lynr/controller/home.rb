require 'json'
require 'rest-client'

require './lib/lynr'
require './lib/lynr/controller/base'
require './lib/lynr/controller/form_helpers'
require './lib/lynr/validator/helpers'

module Lynr; module Controller;

  # # `Lynr::Controller::Home`
  #
  # Controller to handle requests for the root resource.
  #
  class Home < Lynr::Controller::Base

    include Lynr::Controller::FormHelpers

    get  '/', :index

    def initialize
      super
      if Lynr.features.demo?
        self.send(:extend, Home::Demo)
      end
    end

    def before_GET(req)
      super
      @section = 'home'
      @title = 'Lynr.co'
    end

    # ## `Home#index(req)`
    #
    # Process a GET request for the root resource.
    #
    def index(req)
      log.info('type=measure.render template=index.erb')
      Lynr.metrics.time('time.render:home.index') do
        render template_path, layout: 'marketing/default.erb'
      end
    end

    def template_path() 'index.erb' end

    module Demo

      def template_path() 'demo/index.erb' end

    end

  end

end; end;
