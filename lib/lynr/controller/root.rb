require './lib/lynr/controller/base'

module Lynr; module Controller;

  # # `Lynr::Controller::Root`
  #
  # `Root` is the catch all controller. It will handle everything
  # not mapped elsewhere in the project.
  class Root < Lynr::Controller::Base

    map '/'

    layout :mobile_default

    before(:index) do
      log.info "Request  - '#{request.path_info}'"
    end

    after(:index) do
      log.info "Response - '#{request.path_info}' -- #{response.status}"
    end

    # ## `Lynr::Controller::Root#index`
    #
    # Homepage. Automagically renders `views/index.erb` based on the method name
    # servicing the request, in this case `index`
    def index
      @title = "Hi there!"
    end

  end

end; end;
