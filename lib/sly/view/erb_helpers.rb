require './lib/sly/view/erb'

module Sly; module View;

  module ErbHelpers

    include ERB::Util

    def render(view, opts={})
      options = self.class.render_options.merge(opts)
      template = ::File.join(Sly::App.options.root, Sly::App.options.views, view.to_s)
      layout = ::File.join(Sly::App.options.root, Sly::App.options.layouts, options[:layout].to_s) if options.has_key?(:layout)
      view = Sly::View::Erb.new(template, { layout: layout, context: self })
      Rack::Response.new(view.result, 200, @headers)
    end

    def render_partial(path)
      partial = ::File.join(Sly::App.options.root, Sly::App.options.partials, path.to_s)
      partial_view = Sly::View::Erb.new(partial, { context: self })
      partial_view.result
    end

    def self.included(into)
      into.extend SingletonMethods
    end

    module SingletonMethods

      def set_render_options(opts={})
        @_sly_render_opts = opts
      end

      def render_options
        @_sly_render_opts || {}
      end

    end # SingletonMethods

  end # ErbHelpers

end; end;
