require 'libxml'

module DataOne

  # # `DataOne::Api::Response`
  #
  # Pull the errors or vehicle information out of a DataOne response.
  #
  class Api::Response

    include Lynr::Converter::DataOne

    # # `DataOne::Api::Response::Error`
    #
    # Represent an API error from the `decoder_error` object within an
    # XML response.
    #
    Error = Struct.new(:code, :message)

    # ## `Api::Response.new(xml)`
    #
    # Public: Create a response from an XML string.
    #
    # * `xml` - XML string to be parsed from DataOne.
    #
    # Returns a new instance of a `DataOne::Api::Response` using the
    # string of `xml` provided.
    #
    def initialize(xml)
      @xml = xml
    end

    # ## `Api::Response#document`
    #
    # Internal: Create a `LibXML::XML::Document` from the `xml` data
    # provided when the `Api::Response` was created.
    #
    # Returns a memoized `LibXML::XML::Document` created from `@xml`.
    #
    def document
      @document ||= LibXML::XML::Document.string(@xml)
    end

    # ## `Api::Response#errors`
    #
    # Public: Parse the errors out of `#document`.
    #
    # Returns an `Array` of `DataOne::Api::Response::Error` instances.
    #
    def errors
      @errors ||= document.find('//decoder_errors/error').map do |node|
        Error.new(content(node, './code'), content(node, './message'))
      end
    end

    # ## `Api::Response#success?`
    #
    # Public: Whether or not the request contained errors.
    #
    # Returns true if `#errors` is empty, false otherwise.
    #
    def success?
      errors.length == 0
    end

  end

end
