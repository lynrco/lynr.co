require 'libxml'

require './lib/ebay'

module Ebay

  # # `Ebay::Session`
  #
  # Represent the data retrieved from the Ebay API for getting a session.
  #
  class Session

    EMPTY_RESPONSE = <<-EOF
<?xml version="1.0" encoding="UTF-8"?><GetSessionIDResponse xmlns="#{Ebay::NS}" />
    EOF

    attr_reader :id, :valid
    alias :valid? :valid

    # ## `Session.new(response)`
    #
    # Extract the session id from xml `response`. If `response` is malformed or
    # didn't come back with `Ack` element with content of Success then `#id` will
    # be `nil` and `Session#valid?` will be false.
    #
    def initialize(response)
      response = EMPTY_RESPONSE if response.nil?
      reader = LibXML::XML::Reader.string(response)
      @id = nil
      @valid = false
      while reader.read
        next unless reader.node_type == LibXML::XML::Reader::TYPE_ELEMENT
        n = reader.node
        case n.name
          when 'Ack'
            @valid = n.content == 'Success'
          when 'SessionID'
            @id = n.content
        end
      end
    rescue LibXML::XML::Error
      # Do nothing, defaults are already set
    ensure
      reader.close
    end

  end

end
