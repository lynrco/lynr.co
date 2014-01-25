require 'erb'

module Sly; module View;

  # # `Sly::View::Erb`
  #
  # The `Erb` class provides a simple interface by which .erb template files
  # can be processed.
  #
  class Erb

    # ## `Sly::View::Erb.new(path, options)`
    #
    # `Erb` instances are created by an absolute `path` to the .erb template file
    # (.erb at the end of the filename is optional) and a `Hash` of options.
    #
    # ### Options
    #
    # * `:layout` .erb template to evaluate outside of the .erb template given as
    #     `path`. The result of evaluating `path` is output for a `yield` statement
    #     in `:layout`.
    # * `:context` `::Binding` under which to evalate the .erb template. Methods and
    #     @attributes will be evaluated as if called on context.
    # * `:data` `::Hash` used to look up properties. `Sly::View::Erb` evaluates the
    #     .erb file in the context of this instance if `:context` option is not
    #     provided. This is how to inject data into the binding.
    #
    def initialize(path, opts = {})
      @layout = get_template(opts[:layout]) if opts[:layout]
      @template = get_template(path) if path
      @context = opts[:context]
      @data = opts[:data] || {}
    end

    # ## `Sly::View::Erb#result`
    #
    # Returns the result of processing the .erb file at path provided in constructor
    # with the given options.
    #
    def result
      if (@context && @layout)
        # In order for `yield` to work in the layout template there needs to be a
        # block in scope of the binding. In this case the return value of the block is
        # the output of processing `@template` in the same context.
        @layout.result(@context.ctx { @template.result(@context.ctx) })
      elsif (@context)
        @template.result(@context.ctx)
      elsif (@layout)
        @layout.result(binding { @template.result(binding) })
      else
        @template.result(binding)
      end
    end

    # ## `Sly::View::View#method_missing(name, *args, &block)`
    #
    # If method is an accessor (no arguments) and the :data options was passed and
    # includes the property as a string or symbol then return the value of the property
    # from the :data option. Otherwise call `super`
    #
    def method_missing(name, *args, &block)
      if args.size == 0 && block.nil? && (@data.include?(name.to_s) || @data.include?(name.to_sym))
        @data[name.to_s] || @data[name.to_sym]
      else
        super
      end
    end

    private

    # ## `Sly::View::Erb#get_template(path)`
    #
    # *Private* method to get an `::Erb` instance based on the provided absolute path.
    #
    def get_template(path)
      file_name = path.to_s
      file_name = "#{file_name}.erb" unless file_name.end_with? ".erb"
      str = ::File.read(file_name)
      ::ERB.new(str, nil, '-')
    end

  end

end; end;
