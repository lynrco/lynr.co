require './lib/lynr/controller/base'

module Lynr; module Controller;

  class Root < Lynr::Controller::Base

    get '/' do
      erb :index, layout: :'layout/mobile_default'
    end

  end

end; end;
