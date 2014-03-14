require 'rspec/autorun'
require './spec/spec_helper'

require './lib/ebay/api/response'

describe Ebay::Api::Response do

  LibXML::XML::Error.reset_handler

  let(:simple_success) {
    <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<FetchTokenResponse xmlns="urn:ebay:apis:eBLBaseComponents">
  <Timestamp>2010-11-10T20:42:58.943Z</Timestamp>
  <Ack>Success</Ack>
  <Version>693</Version>
  <Build>E693_CORE_BUNDLED_12301500_R1</Build>
  <eBayAuthToken>YourAuthToken</eBayAuthToken>
  <HardExpirationTime>2012-05-03T20:36:32.000Z</HardExpirationTime>
</FetchTokenResponse>
    EOF
  }
  let(:valid_failure) {
    <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<FetchTokenResponse xmlns="urn:ebay:apis:eBLBaseComponents">
  <Timestamp>2014-01-06T21:47:32.194Z</Timestamp>
  <Ack>Failure</Ack>
  <Errors>
    <ShortMessage>Invalid value for header &quot;X-EBAY-API-COMPATIBILITY-LEVEL&quot;.</ShortMessage>
    <LongMessage>Header &quot;X-EBAY-API-COMPATIBILITY-LEVEL&quot; with value &quot;(null)&quot; is out \
of range.</LongMessage>
    <ErrorCode>10012</ErrorCode>
    <SeverityCode>Error</SeverityCode>
    <ErrorParameters ParamID="0">
      <Value>X-EBAY-API-COMPATIBILITY-LEVEL</Value>
    </ErrorParameters>
    <ErrorParameters ParamID="1">
      <Value>(null)</Value>
    </ErrorParameters>
    <ErrorClassification>RequestError</ErrorClassification>
  </Errors>
  <Version>851</Version>
  <Build>E851_CORE_API_16556829_R1</Build>
</FetchTokenResponse>
    EOF
  }
  let(:invalid) { '<?xml version="1.0" encoding="UTF-8"?><G' }

  describe "#fetch" do

    context "nil XML" do

      let(:response) { Ebay::Api::Response.new(nil) }

      it "is `nil` for nonsense element" do
        expect(response.fetch('Foo')).to be_nil
      end

      it "is `nil` for known element" do
        expect(response.fetch('Timestamp')).to be_nil
      end

      it "is default if provided" do
        expect(response.fetch('Timestamp', '2014-01-06')).to eq('2014-01-06')
      end

    end

    context "well formed XML" do

      let(:response) { Ebay::Api::Response.new(valid_failure) }

      it "gets the value of a matching element" do
        expect(response.fetch('Timestamp')).to eq('2014-01-06T21:47:32.194Z')
      end

      it "is `nil` if no matching element and no default" do
        expect(response.fetch('Foo')).to be_nil
      end

      it "is default if no matching element" do
        expect(response.fetch('Foo', 'bar')).to eq('bar')
      end

      it "gets the first value of a matching element" do
        expect(response.fetch('Value')).to eq('X-EBAY-API-COMPATIBILITY-LEVEL')
      end

    end

    context "mal-formed XML" do

      let(:response) { Ebay::Api::Response.new(invalid) }

      it "gets nil when no default" do
        expect(response.fetch('Timestamp')).to be_nil
      end

      it "gets the default" do
        expect(response.fetch('Ack', 'Failure')).to eq('Failure')
      end

    end

  end

  describe "#success?" do

    it "is false when <Ack> is Failure" do
      response = Ebay::Api::Response.new(valid_failure)
      expect(response.success?).to be_false
    end

    it "is false when <Ack> doesn't exist" do
      response = Ebay::Api::Response.new('<?xml version="1.0" encoding="UTF-8"?><G></G>')
      expect(response.success?).to be_false
    end

    it "is false when XML is mal-formed" do
      response = Ebay::Api::Response.new(invalid)
      expect(response.success?).to be_false
    end

    it "is false when XML is nil" do
      response = Ebay::Api::Response.new(nil)
      expect(response.success?).to be_false
    end

    it "is true when <Ack> exists and contains 'Success'" do
      response = Ebay::Api::Response.new(simple_success)
      expect(response.success?).to be_true
    end

  end

end
