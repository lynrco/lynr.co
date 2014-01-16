module Lynr; module View;

  # # `Lynr::View::Menu`
  #
  # Simple view class to hold information about a menu so it can be rendered
  # generically in a layout or template.
  #
  class Menu

    attr_reader :text, :href, :partial, :icon

    # ## `Lynr::View::Menu.new(text, href, partial)`
    #
    # Create a new `Menu` instance holding information about text, href and partial.
    # Text is what to display as the text for the menu icon. Href is the link to
    # show the page with the menu content already shown. Partial is the menu template
    # to render.
    #
    def initialize(text, href, partial, icon="icon-menu")
      @text = text
      @href = href
      @partial = partial
      @icon = icon
    end

    # ## `Lynr::View::Menu#set_href(href)`
    #
    # Generate a new Menu instance with the same `text` and `partial` values but a
    # new `href` value.
    #
    def set_href(href)
      Menu.new(@text, href, @partial, @icon)
    end

    def set_icon(icon)
      Menu.new(@text, @href, @partial, icon)
    end

  end

end; end;
