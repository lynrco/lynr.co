require './lib/lynr/controller/base'

module Lynr; module Controller;

  class Home < Lynr::Controller::Base

    get  '/', :index

    def index(req)
      @section = 'home'
      log.info('Rendering index.erb')
      render 'index.erb'
    end

  end

end; end;
