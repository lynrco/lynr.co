require './lib/lynr'
require './lib/sly/view/erb_helpers'

module Lynr::View

  # # `Lynr::View::Renderer`
  #
  # Class to encapsulate the logic of rendering an ERB template from a Controller.
  # This class will make it easier to not use instance variables all over templates
  # by encouraging sending the data as a Hash while collecting common Lynr view
  # configuration options.
  #
  class Renderer

    include Sly::View::ErbHelpers

    attr_reader :headers

    # ## `Renderer.new(template, data)`
    #
    # Create a new renderable view for `template` using `data`. Some of the options
    # to `data` are special:
    #
    # * `:headers` [Hash] each key => value pair is included as a header in the `Rack::Response`
    # * `:title` [String] set as `@title` for use in layout
    # * `:section` [String] set as `@section` for use in layout
    # * `:subsection` [String] set as `@subsection` for use in layout
    #
    def initialize(template, data={})
      @data = data
      @headers = data.fetch(:headers, {})
      @title = data.fetch(:title, '')
      @section = data.fetch(:section '')
      @subsection = data.fetch(:subsection '')
      @template = template
    end

    # ## `Renderer#ctx`
    #
    # Provide access to the `Kernel::Binding` for this instance.
    #
    def ctx
      binding
    end

    # ## `Renderer#method_missing(name, *args, &block)`
    #
    # Implement Ruby 'magic' method to allow access to `data` properties by using
    # a dot notation. If backing `data` doesn't include a value for method `name`
    # invoke `super`.
    #
    def method_missing(name, *args, &block)
      if args.size == 0 && block.nil? && (@data.include?(name.to_s) || @data.include?(name.to_sym))
        @data[name.to_s] || @data[name.to_sym]
      else
        super
      end
    end

    # ## `Renderer#render_options`
    #
    # Override `Sly::View::ErbHelpers::DEFAULTS`
    #
    def render_options
      super.merge({ root: Lynr.root, layout: 'default.erb', layouts: 'layout' })
    end

    # ## `Renderer#render`
    #
    # Proxy to `Sly::View::ErbHelpers#render` with the template and data provided
    # to constructor of this instance.
    #
    def render
      super(@template, @data)
    end

  end

end
