require './lib/sly/view/erb'

module Sly; module View;

  module ErbHelpers

    include ERB::Util

    def render(view, opts={})
      template = ::File.join(Sly::App.options.root, Sly::App.options.views, view.to_s)
      layout = ::File.join(Sly::App.options.root, Sly::App.options.layouts, opts[:layout].to_s) if opts.has_key?(:layout)
      view = Sly::View::Erb.new(template, { layout: layout, context: self })
      Rack::Response.new(view.result, 200, @headers)
    end

    def render_partial(path)
      partial = ::File.join(Sly::App.options.root, Sly::App.options.partials, path.to_s)
      partial_view = Sly::View::Erb.new(partial, { context: self })
      partial_view.result
    end

  end

end; end;
