require './lib/sly'
require './lib/lynr/controller/base'
require './lib/lynr/persist/dealership_dao'
require './lib/lynr/validator/helpers'

module Lynr; module Controller;

  # # `Lynr::Controller::Admin`
  #
  # `Admin` is the catch all controller for admin pages. It will handle
  # everything under '/admin' not mapped elsewhere.
  #
  class Admin < Lynr::Controller::Base

    attr_reader :dao

    def initialize
      super
      @section = "admin"
      @dao = Lynr::Persist::DealershipDao.new
    end

    get '/admin/:slug', :index

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
