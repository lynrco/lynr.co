module Sly; module View;

  class Erb

    def initialize(path, opts)
      layout_path = opts[:layout] || nil
      @layout = get_template(layout_path) if layout_path
      @template = get_template(path) if path
      @context = opts[:context] || nil
      if !@context.respond_to? :ctx
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

    private

    def get_template(path)
      file_name = path.to_s
      file_name = "#{file_name}.erb" unless file_name.end_with? ".erb"
      str = ::File.read(file_name)
      ::ERB.new(str, nil, '-')
    end

  end

end; end;
