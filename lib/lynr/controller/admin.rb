require './lib/sly'
require './lib/sly/view/erb_helpers'
require './lib/lynr/validator/helpers'
require './lib/lynr/persist/dealership_dao'

require './lib/lynr/controller/base'
require './lib/lynr/persist/dealership_dao'

module Lynr; module Controller;

  # # `Lynr::Controller::Admin`
  #
  # `Admin` is the catch all controller for admin pages. It will handle
  # everything under '/admin' not mapped elsewhere.
  #
  class Admin < Sly::Node

    include Lynr::Logging
    # Provides `is_valid_email?`
    include Lynr::Validator::Helpers
    # Provides `render` and `render_partial` methods
    include Sly::View::ErbHelpers

    attr_reader :dao

    def initialize
      super
      @headers = {
        "Content-Type" => "text/html; charset=utf-8",
        "Server" => "Lynr.co Application Server"
      }
      @section = "admin"

      @dao = Lynr::Persist::DealershipDao.new
    end

    get '/admin/:slug', :index

    set_render_options({ layout: 'default_sly.erb' })

    # ## `Lynr::Controller::Admin#index`
    #
    # Admin Homepage. Renders `views/admin/index.erb`.
    #
    def index(req)
      @subsection = 'index'
      id = BSON::ObjectId.from_string(req['slug'])
      @dealership = dao.get(id)
      return not_found if @dealership.nil?
      @title = "Welcome back #{@dealership.name}"
      @owner = @dealership.name
      render 'admin/index.erb'
    end

  end

end; end;
