require './lib/lynr/controller/base'

module Lynr; module Controller;

  class Root < Lynr::Controller::Base

    get '/' do
      log.info "Request  - '#{request.path_info}'"
      erb :index
    end

  end

end; end;
