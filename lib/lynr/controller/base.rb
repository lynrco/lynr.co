require 'ramaze'

module Lynr; module Controller;

  class Base < Ramaze::Controller

    include Lynr::Logging

    engine :erb

    before_all do
      log.info "Request  - '#{request.path_info}'"
    end

    after_all do
      log.info "Response - '#{request.path_info}' -- #{response.status}"
      response['Server'] = 'Lynr.co Application Server'
    end

  end

end; end;
