require './lib/sly/view/erb'

module Sly; module View;

  # Mixed in to add instance methods
  module ErbHelpers

    include ::ERB::Util

    def render(view, opts={ status: 200 })
      options = render_options.merge(opts)
      template = ::File.join(Sly::App.options.root, Sly::App.options.views, view.to_s)
      layout = ::File.join(Sly::App.options.root, Sly::App.options.layouts, options[:layout].to_s) if options.has_key?(:layout)
      context = self unless options.has_key?(:data)
      view = Sly::View::Erb.new(template, { layout: layout, context: context, data: options[:data] })
      Rack::Response.new(view.result, options.fetch(:status, 200), @headers)
    end

    def render_partial(path)
      render_inline(path, Sly::App.options.partials)
    end

    def render_view(path)
      render_inline(path, Sly::App.options.views)
    end

    private
    
    def render_inline(path, type)
      partial = ::File.join(Sly::App.options.root, type, path.to_s)
      partial_view = Sly::View::Erb.new(partial, { context: self })
      partial_view.result
    end

    def render_options
      (self.class.respond_to?(:render_options) && self.class.render_options) || {}
    end

    # Mixed in to add class methods
    module ClassMethods

      def set_render_options(opts={})
        @_sly_render_opts = opts
      end

      def render_options
        opts = (self.superclass.respond_to?(:render_options) && self.superclass.render_options) || {}
        opts.merge(@_sly_render_opts || {})
      end

    end # ClassMethods

  end # ErbHelpers

end; end;
