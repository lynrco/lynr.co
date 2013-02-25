require 'sinatra/base'
require 'sinatra/partial'

module Lynr; module Controller;

  class Base < Sinatra::Base

    register Sinatra::Partial
    include Lynr::Logging

    enable :logging

    set :root, File.dirname(__FILE__) + '/../../..'
    set :public_folder, settings.root + '/public'
    set :views, settings.root + '/views'
    set :partial_template_engine, :erb

    before do
      log.info "Request  - '#{request.path_info}'"
    end

    after do
      log.info "Response - '#{request.path_info}' -- #{response.status}"
      response['Server'] = 'Lynr.co Application Server'
    end

  end

end; end;
