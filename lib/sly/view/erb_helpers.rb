require 'rack'

require './lib/sly/view/erb'

module Sly; module View;

  # Mixed in to add instance methods
  module ErbHelpers

    include ::ERB::Util

    DEFAULTS = {
      root: File.dirname($0),
      layouts: 'layouts',
      partials: 'partials',
      views: 'views',
    }

    def render(view, opts={ status: 200 })
      options = _render_options(opts)
      template = ::File.join(*[options[:root], options[:views], view.to_s].compact)
      layout = ::File.join(*[options[:root], options[:layouts], options[:layout].to_s].compact) if options.has_key?(:layout)
      context = self unless options.has_key?(:data)
      view = Sly::View::Erb.new(template, { layout: layout, context: context, data: options[:data] })
      Rack::Response.new(view.result, options.fetch(:status, 200), @headers)
    end

    def render_options
      DEFAULTS
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

    def _render_options(opts)
      opts = {} if opts.nil?
      options = if (self.respond_to?(:render_options)) then self.render_options
                else DEFAULTS
                end
      options.merge(opts)
    end

  end # ErbHelpers

end; end;
