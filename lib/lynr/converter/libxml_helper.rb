require 'libxml'

module Lynr; module Converter;

  module LibXmlHelper

    def contents(context, xpath)
      enum = context.find(xpath) if context
      (enum || []).map { |node| node.content }
    end

    def values(context, xpath)
      enum = context.find(xpath) if context
      (enum || []).map { |node| node.value }
    end

  end

end; end;
