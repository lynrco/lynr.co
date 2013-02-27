require './lib/lynr/controller/base'

module Lynr; module Controller;

  class Root < Lynr::Controller::Base

    map '/'

    layout :mobile_default

    def index
      @title = "Hi there!"
    end

  end

end; end;
