require 'erb'

module Sly; module View;

  class Erb

    def initialize(path, opts = {})
      @layout = get_template(opts[:layout]) if opts[:layout]
      @template = get_template(path) if path
      @context = opts[:context]
      @data = opts[:data] || {}
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
