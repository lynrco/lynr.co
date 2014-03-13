require 'kramdown'

require './lib/lynr'
require './lib/lynr/controller/base'
require './lib/lynr/model/slug'

module Lynr::Controller

  class Legal < Lynr::Controller::Base

    get  '/legal',                :get
    get  '/legal/:type',          :get
    get  '/legal/:version/:type', :get

    def initialize
      @section = 'legal'
      @title = 'Lynr Legal'
    end

    def before_each(req)
      super
      @dealership = session_user(req)
    end

    def get(req)
      return not_found unless ::File.exists?(file_path(req))
      @title = header(req).options[:raw_text] unless header(req).nil?
      @subsection = Lynr::Model::Slug.new(type(req))
      @legal_html = document(req).to_html
      render 'legal.erb'
    end

    def config
      return @config unless @config.nil?
      @config = Lynr.config('app').legal
    end

    def document(req)
      return @document unless @document.nil?
      @document = Kramdown::Document.new(markdown(req))
    end

    def file_path(req)
      ::File.join(Lynr.root, 'public/legal', "#{version(req)}/#{type(req)}.md")
    end

    def header(req)
      return @header unless @header.nil?
      @header = document(req).root.children.find do |el|
          el.type == :header && el.options[:level] == 1
        end
    end

    def markdown(req)
      ::File.read(file_path(req))
    end

    def type(req)
      req.params.fetch('type', default='terms')
    end

    def version(req)
      req.params.fetch('version', default=config.current)
    end

  end

end
