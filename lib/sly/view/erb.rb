require 'erb'

module Sly; module View;

  class Erb

    def initialize(path, opts)
      layout_path = opts[:layout]
      @layout = get_template(layout_path) if layout_path
      @template = get_template(path) if path
      @context = opts[:context]
      @data = opts[:data] || {}
      if (!@context.nil? && !@context.respond_to?(:ctx))
        raise ArgumentError.new("`:context` option must have a public `ctx` method")
      end
    end

    def result
      if (@layout)
        @layout.result(@context.ctx { @template.result(@context.ctx) })
      elsif (@context)
        @template.result(@context.ctx)
      else
        @template.result(binding)
      end
    end

    def method_missing(name, *args, &block)
      if args.size == 0 && block.nil? && (@data.include?(name.to_s) || @data.include?(name.to_sym))
        @data[name.to_s] || @data[name.to_sym]
      else
        super
      end
    end

    private

    def get_template(path)
      file_name = path.to_s
      file_name = "#{file_name}.erb" unless file_name.end_with? ".erb"
      str = ::File.read(file_name)
      ::ERB.new(str, nil, '-')
    end

  end

end; end;
