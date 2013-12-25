require 'rack'

require './lib/sly/view/erb'

module Sly; module View;

  # # `Sly::View::ErbHelpers`
  #
  # This module provides methods to make it easier to generate markup from .erb
  # files. The primary method to use is `#render` as it results in a `Rack::Response`
  # which can be used immediately. It is likely the implementor will need to override
  # the `#render_options` instance method to customize settings and behavior for the
  # including class. See the `#render_options` documentation for more information on
  # options.
  #
  module ErbHelpers

    include ::ERB::Util

    DEFAULTS = {
      root: File.dirname($0),
      layouts: 'layouts',
      partials: 'partials',
      views: 'views',
    }

    # ## `Sly::View::ErbHelpers#render`
    #
    # This method is the primary way to generate a response from an .erb view.
    # `#render` generates the response body from the .erb file `path` provided and
    # creates a `Rack::Response` with `:status` from `opts` and headers from the
    # including class. `#render` requires an instance method of `#headers` to be defined,
    # if it isn't `#render` will fail with a `MethodNotDefined` error.
    #
    # ### Params
    #
    # * `path` relative to `#render_options[:views]`, of the .erb file to use for
    #     creating the response body.
    # * `opts` is a `Hash` which can be used to override the values provided by
    #     `#render_options`
    #
    # ### Options
    #
    # `#render` handles the following keys from `#render_options` which are not used
    # elsewhere.
    #
    # * `:status` is the HTTP status code given to the `Rack::Response`. Defaults to 200.
    #
    # ### Returns
    #
    # A `Rack::Response` with the parsed `path` as the body, headers from the including
    # class and status code from the options.
    #
    def render(path, opts={ status: 200 })
      options = _render_options(opts)
      options[:with_layout] = true if options.has_key?(:layout)
      view = render_inline(path, :views, options)
      Rack::Response.new(view, options.fetch(:status, 200), headers)
    end

    # ## `Sly::View::ErbHelpers#render_options`
    #
    # Method used to define the erb rendering options for this including class.
    # `#render_options` returns a `Hash` of options.
    #
    # ### Options
    #
    # These options are provided in a `Hash` returned by `ErbHelpers#render_options`.
    # This method can and should be overridden to provide suitable defaults for rendering
    # your projects erb files. These `render_options` default to the values in
    # `Sly::View::ErbHelpers::DEFAULTS`.
    #
    # * `:root`, directory the root resides in. Used as the basis for template path
    #     generation. Defaults to directory of the script being executed.
    # * `:views`, path -- from root -- to the location of views. Defaults to 'views'.
    # * `:layouts`, path -- from root -- to the location of layouts. Defaults to 'layouts'.
    # * `:partials`, path -- from root -- to the location of partials. Defaults to 'partials'.
    # * `:layout`, path -- from layouts -- to the location of the layout file. Layout file
    #     is optional and is only used when calling `#render`. It sets the template
    #     when rendering.
    #
    # ### Returns
    #
    # `Hash` with specific options to override.
    #
    def render_options
      DEFAULTS
    end

    # ## `Sly::View::ErbHelpers#render_partial`
    #
    # Intended to be used within an .erb template. `#render_partial` looks for `path`
    # in the folder defined by `#render_options[:partials]` and processes it in the
    # context of `#render_options[:data]` or this instance.
    #
    # ### Params
    #
    # * `path` defines the path within `:partials` for the .erb file
    #
    # ### Returns
    #
    # The `String` result of processing the .erb file
    #
    def render_partial(path)
      render_inline(path, :partials)
    end

    # ## `Sly::View::ErbHelpers#render_view`
    #
    # Intended to be used within an .erb template. `#render_view` looks for `path`
    # in the folder defined by `#render_options[:views]` and processes it in the context
    # of `#render_options[:data]` or this instance.
    #
    # ### Params
    #
    # * `path` defines the path within `:partials` for the .erb file
    #
    # ### Returns
    #
    # The `String` result of processing the .erb file
    #
    def render_view(path)
      render_inline(path, :views)
    end

    private

    # ## `Sly::View::ErbHelpers#render_inline`
    #
    # This is the *private* method that does the work of processing the options and
    # sending them to `Sly::View::Erb` for processing.
    #
    def render_inline(path, type, opts={})
      options = _render_options(opts)
      template = ::File.join(*[options[:root], options[type], path.to_s].compact)
      layout = ::File.join(*[options[:root], options[:layouts], options[:layout].to_s].compact)
      view_opts = { data: options[:data] }
      view_opts[:context] = self unless options.has_key?(:data)
      view_opts[:layout] = layout if options[:with_layout]
      Sly::View::Erb.new(template, view_opts).result
    end

    # ## `Sly::View::ErbHelpers#_render_options`
    #
    # *Private* method for putting together the defaults, `#render_options` and
    # options passed in as an argument.
    #
    def _render_options(opts)
      opts = {} if opts.nil?
      DEFAULTS.merge(render_options.merge(opts))
    end

  end # ErbHelpers

end; end;
