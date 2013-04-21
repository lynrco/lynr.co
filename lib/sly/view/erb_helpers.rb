require 'sly/view/erb'

module Sly; module View;

  module ErbHelpers

    include ERB::Util

    def render(view, opts={ status: 200 })
      options = self.class.render_options.merge(opts)
      template = ::File.join(Sly::App.options.root, Sly::App.options.views, view.to_s)
      layout = ::File.join(Sly::App.options.root, Sly::App.options.layouts, options[:layout].to_s) if options.has_key?(:layout)
      context = self unless options.has_key?(:data)
      view = Sly::View::Erb.new(template, { layout: layout, context: context, data: options[:data] })
      Rack::Response.new(view.result, options[:status], @headers)
    end

    def render_partial(path)
      partial = ::File.join(Sly::App.options.root, Sly::App.options.partials, path.to_s)
      partial_view = Sly::View::Erb.new(partial, { context: self })
      partial_view.result
    end

    
    ##
    # Extends the class that included this module so that the methods that
    # this helper provides can be called outside of a class instance.
    #
    # Taken from [Ramaze's layout module][layout_module]
    #
    # [layout_module]: https://github.com/Ramaze/ramaze/blob/5eca0714b37e3d3b618929e35a7b0a447ff16ec3/lib/ramaze/helper/layout.rb
    def self.included(into)
      into.extend SingletonMethods
    end

    module SingletonMethods

      def set_render_options(opts={})
        @_sly_render_opts = opts
      end

      def render_options
        opts = (self.superclass.respond_to?(:render_options) && self.superclass.render_options) || {}
        opts.merge(@_sly_render_opts || {})
      end

    end # SingletonMethods

  end # ErbHelpers

end; end;
