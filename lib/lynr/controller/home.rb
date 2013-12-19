require './lib/lynr/controller/base'

module Lynr; module Controller;

  class Home < Lynr::Controller::Base

    get  '/', :index

    def index(req)
      @section = 'home'
      log.info('type=measure.render template=index.erb')
      render 'index.erb', layout: 'marketing/default.erb'
    end

  end

end; end;
