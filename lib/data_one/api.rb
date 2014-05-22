require './lib/lynr/converter/data_one'

module DataOne

  # # `DataOne::Api`
  #
  # Encapsulates the logic for retrieving data from the DataOne API.
  #
  class Api

    include Lynr::Converter::DataOne

    # ## `DataOne::Api#dataone_xml_query(vin)`
    #
    # Helper method to render query template with the appropriate
    # `vin` request data.
    #
    def dataone_xml_query(vin)
      path = ::File.join(Lynr.root, 'views/admin/vehicle/dataone_request')
      Sly::View::Erb.new(path, data: { vin: vin }).result
    end

    # ## `DataOne::Api.fetch(vin)`
    #
    # Request information from the DataOne API about the vehicle
    # identified by `vin`. This class method is provided as a
    # convenience to avoid the need to instantiate an `Api` class at the
    # call site.
    #
    def self.fetch(vin)
      Api.new.fetch(vin)
    end

    # ## `DataOne::Api#fetch(vin)`
    #
    # Retrieve vehicle data formatted like a response from the the DataOne
    # API and return a `LibXML::XML::Node` with the `<query_response />`
    # element from the response. This method will look for cached responses
    # before reaching out over the wire to the DataOne API.
    #
    def fetch(vin)
      if File.exist?("spec/data/#{vin}.xml")
        doc = LibXML::XML::Document.file("spec/data/#{vin}.xml")
      elsif Lynr.cache.include?(vin)
        doc = LibXML::XML::Document.string(Lynr.cache.read(vin))
      elsif Lynr.features.dataone_decode
        response = fetch_dataone(vin).tap { |resp| Lynr.cache.write(vin, resp) }
        doc = LibXML::XML::Document.string(response)
      else
        doc = LibXML::XML::Document.new
        node = LibXML::XML::Node.new 'query_response'
        doc.root = node
      end
      doc.find_first("//query_response[@identifier='#{vin}']")
    end

    # ## `DataOne::Api#fetch_dataone(vin)`
    #
    # Execute the API call against the DataOne API.
    #
    def fetch_dataone(vin)
      config = Lynr.config('app').vin.dataone
      url = config.url
      data = {
        authorization_code: config.auth_code,
        client_id:          config.client_id,
        decoder_query:      dataone_xml_query(vin),
      }
      Lynr.metrics.time('time.service:dataone.fetch') do
        RestClient.post url, data
      end
    end

  end

end
