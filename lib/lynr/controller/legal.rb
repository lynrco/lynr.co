require 'kramdown'

require './lib/lynr'
require './lib/lynr/controller/base'
require './lib/lynr/model/slug'

module Lynr::Controller

  # # `Lynr::Controller::Legal`
  #
  # Controller to serve up the content of legal pages based on a :type
  # and :version path parameter.
  #
  class Legal < Lynr::Controller::Base

    get  '/legal',                :get
    get  '/legal/:type',          :get
    get  '/legal/:version/:type', :get

    # ## `Legal.new`
    #
    # Setup universal properties.
    #
    def initialize
      @section = 'legal'
      @title = 'Lynr Legal'
    end

    # ## `Legal#get(req)`
    #
    # Process `req` and create a `Rack::Response` based on the type of
    # document and the version provided by the request.
    #
    def get(req)
      return not_found unless ::File.exists?(file_path(req))
      @title = header(req).options[:raw_text] unless header(req).nil?
      @subsection = Lynr::Model::Slug.new(type(req))
      @legal_html = document(req).to_html
      render 'legal.erb'
    end

    # ## `Legal#document(req)`
    #
    # Get the `Kramdown::Document` to use for display based on the data
    # in `req`.
    #
    def document(req)
      return @document unless @document.nil?
      @document = Kramdown::Document.new(markdown(req))
    end

    # ## `Legal#file_path(req)`
    #
    # The absolute filesystem path to the markdown file to use for display
    # based on data extracted from `req`.
    #
    def file_path(req)
      ::File.join(Lynr.root, 'public/legal', "#{version(req)}/#{type(req)}.md")
    end

    # ## `Legal#header(req)`
    #
    # Get the first `<h1>` element from `#document(req)`
    #
    def header(req)
      return @header unless @header.nil?
      @header = document(req).root.children.find do |el|
          el.type == :header && el.options[:level] == 1
        end
    end

    # ## `Legal#markdown(req)`
    #
    # Read the markdown formatted text from `#file_path(req)`
    #
    def markdown(req)
      ::File.read(file_path(req))
    end

    # ## `Legal#type(req)`
    #
    # Get the type of legal document to look for based on `req`.
    #
    def type(req)
      req.params.fetch('type', default='terms')
    end

    # ## `Legal#version(req)`
    #
    # Get the version of legal document to look for based on `req`.
    #
    def version(req)
      req.params.fetch('version', 'current')
    end

  end

end
