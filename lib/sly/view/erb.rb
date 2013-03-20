module Sly; module View;

  class Erb

    def initialize(path, opts)
      layout_path = opts[:layout] || nil
      @layout = get_template(layout_path) if layout_path
      @template = get_template(path) if path
      @context = opts[:context] || nil
    end

    def result
      if (@layout)
        @layout.result(@context.binding { @template.result(@context.binding) })
      else
        @template.result(@context.binding)
      end
    end

    private

    def get_template(path)
      file_name = "#{path.to_s}.erb"
      str = ::File.read(file_name)
      ::ERB.new(str, nil, '%<>')
    end

  end

end; end;
