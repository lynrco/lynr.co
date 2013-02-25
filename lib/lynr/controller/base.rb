require 'sinatra/base'

module Lynr; module Controller;

  class Base < Sinatra::Base

    include Lynr::Logging

    enable :logging

    set :root, File.dirname(__FILE__) + '/../../..'

    after do
      log.info "Response - '#{request.path_info}' -- #{response.status}"
      response['Server'] = 'Lynr.co Application Server'
    end

  end

end; end;
