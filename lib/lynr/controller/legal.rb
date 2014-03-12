require 'kramdown'

require './lib/lynr'
require './lib/lynr/controller/base'
require './lib/lynr/model/slug'

module Lynr::Controller

  class Legal < Lynr::Controller::Base

    get  '/legal/:type', :get

    def initialize
      @section = 'legal'
      @title = 'Lynr Legal'
    end

    def before_each(req)
      super
      @dealership = session_user(req)
    end

    def get(req)
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

    def header(req)
      return @header unless @header.nil?
      @header = document(req).root.children.find do |el|
          el.type == :header && el.options[:level] == 1
        end
    end

    def markdown(req)
      path = ::File.join(Lynr.root, 'public/legal', "#{version(req)}/#{type(req)}.md")
      ::File.read(path)
    end

    def type(req)
      req.params.fetch('type', default='terms')
    end

    def version(req)
      req.params.fetch('version', default=config.current)
    end

  end

end
