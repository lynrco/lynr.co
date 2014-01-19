require 'libxml'

# # `Lynr::Converter`
#
# Namespace module containing modules and methods to help
# translate/transform/convert from serialized data formats (xml/json/bson)
# into `Lynr::Model` instance objects
#
module Lynr; module Converter;

  # # `Lynr::Converter::LibXmlHelper`
  #
  # Module containing methods methods to make extracting data from objects
  # serialized as XML easier.
  #
  module LibXmlHelper

    # ## `Lynr::Converter::LibXmlHelper#content`
    #
    # Get the text content for the first node in a set of nodes matching `xpath`
    # from `context`
    #
    # ### Params
    #
    # * `context` - `LibXML::XML::Node` from whence to find content
    # * `xpath` to find with `context` as the current node
    #
    # ### Returns
    #
    # `nil` if no matching nodes, otherwise first value from an array of the
    # content of nodes matching `xpath` as text.
    #
    def content(context, xpath)
      contents(context, xpath).first
    end

    # ## `Lynr::Converter::LibXmlHelper#contents`
    #
    # Get the text content for the set of nodes matching `xpath` from `context`
    #
    # ### Params
    #
    # * `context` - `LibXML::XML::Node` from whence to find content
    # * `xpath` to find with `context` as the current node
    #
    # ### Returns
    #
    # Empty array if no matching nodes, otherwise an array of the content of
    # nodes matching `xpath` as text.
    #
    def contents(context, xpath)
      enum = context.find(xpath) if context
      (enum || []).map { |node| node.content }
    end

    # ## `Lynr::Converter::LibXmlHelper#value`
    #
    # Get the first value from the set of nodes matching `xpath` from `context`.
    # `xpath` is expected to match attribute nodes.
    #
    # ### Params
    #
    # * `context` - `LibXML::XML::Node` from whence to find values
    # * `xpath` to find with `context` as the current node
    #
    # ### Returns
    #
    # `nil` if no matching nodes, otherwise the first in an array of the values of
    # attribute nodes matching `xpath`.
    #
    def value(context, xpath)
      values(context, xpath).first
    end

    # ## `Lynr::Converter::LibXmlHelper#values`
    #
    # Get the value for the set of nodes matching `xpath` from `context`.
    # `xpath` is expected to match attribute nodes.
    #
    # ### Params
    #
    # * `context` - `LibXML::XML::Node` from whence to find values
    # * `xpath` to find with `context` as the current node
    #
    # ### Returns
    #
    # Empty array if no matching nodes, otherwise an array of the values of
    # attribute nodes matching `xpath`.
    #
    def values(context, xpath)
      enum = context.find(xpath) if context
      (enum || []).map { |node| node.value }
    end

  end

end; end;
