require 'sly/view/erb_helpers'

module Lynr; module View;

  class Menu

    include Sly::View::ErbHelpers

    attr_reader :text, :href, :partial

    def initialize(text, href, partial)
      @text = text
      @href = href
      @partial = partial
    end

    def set_href(href)
      Menu.new(@text, href, @partial)
    end

  end

end; end;
