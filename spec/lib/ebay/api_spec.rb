require 'rspec/autorun'
require './spec/spec_helper'

require 'log4r'
require 'uri'

require './lib/lynr'
require './lib/ebay/api'

describe Ebay::Api, ebay: true do

  before(:each) { Ebay::Api.log.level = Log4r::FATAL }

  let(:config) { Lynr.config('app').ebay }
  let(:valid_session) {
    <<-EOF
<GetSessionIDResponse xmlns="urn:ebay:apis:eBLBaseComponents">
  <Timestamp>2014-01-06T22:34:17.745Z</Timestamp>
  <Ack>Success</Ack>
  <Version>851</Version>
  <Build>E851_CORE_API_16556829_R1</Build>
  <SessionID>+3cCAA**69b135111430a471d220cf50ffffff72</SessionID>
</GetSessionIDResponse>
    EOF
  }
  let(:valid_token) {
    <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<FetchTokenResponse xmlns="urn:ebay:apis:eBLBaseComponents">
  <Timestamp>2014-01-08T23:36:46.104Z</Timestamp>
  <Ack>Success</Ack>
  <Version>853</Version>
  <Build>E853_CORE_API_16609591_R1</Build>
  <eBayAuthToken>AgAAAA**AQAAAA**aAAAAA**A+HNUg**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhC5eAowidj6x9nY+seQ*\
*+3cCAA**AAMAAA**+iEIGKazUGyDne0jAHjhpYmnv/Ul7M6BYufxbOzIlrY9mjzAQV2bM5XUyEjHLZkrb6TZx1zZ2Tb9U8k5pOqTzgJ\
B16pA1YyzJ31sGD+2+GRQ0r9XG6ve+jK0TSk1OnH6wmdxfsP4XzRZka1akouci0Gx2TI7sgXTGdOP9yJQ/gGFCEIdaCA+gtV8hMcniBW\
ZtmfLi0rJH/yQUkZ8ix5IUFoo9+lKGtysGUh3vxla9jvnFSrzAA3q8ii4AcxpTossNlNrRwdlA2FMRro55o8U8x4hyCQdi/Ket5keJtd\
ttf08aVudgVR/l0C76bDtrdVDFEtsfeerj1Nz1+HYeUSCArGU9g1eC9fIgzbEPd9kLOcWIlltbsQWv8BE9h7FhVdHqZhkli343W0gI2E\
GGKO+UOdpb868ebKL+vTZ+L3HxS3iMOn6V3Mtm1ukBFCIEgNxmOfss16WDKtEpfZjpOZ++2N47hy2U+kPssi3KwQHo5iT9mJFkagV9OY\
nK5C5xpZ+sErt8GTd5e0VM7zvpS8TzT2He3Rh5fDQLzmjT345Ofk5MYePf7ld4z5pRc/n+R7z9cFKF7P9jCdq9XRAdjXKW0KsyuV6WvM\
DoEXS4UPv8YT0gmwxwumxb6U0RZ62jnpDJ7cbx0yKu2H7KybP9O4AfS0V5B6gQ1zSFFfysmXtYot/e/sfzt6OqDreSDiScykc5STca8/\
bUX29vmK98uxwrK1eqMS2fgSsV9tC8GUaPZv3WPkJkDWUyOYUWd2EO1CN</eBayAuthToken>
  <HardExpirationTime>2015-07-02T23:36:35.000Z</HardExpirationTime>
</FetchTokenResponse>
    EOF
  }

  describe "properly configured" do

    it "has an appid" do
      expect(config.appid).to match(/([a-zA-Z0-9]+-){4}[a-zA-Z0-9]+/)
    end

    it "has a devid" do
      expect(config.devid).to match(/([a-zA-Z0-9]+-){4}[a-zA-Z0-9]+/)
    end

    it "has a certid" do
      expect(config.certid).to match(/([a-zA-Z0-9]+-){4}[a-zA-Z0-9]+/)
    end

  end

  describe ".session" do

    before(:each) do
      RestClient.stub(:post) do |url, data, headers|
        expect(url).to eq(config.api_url)
        expect(data).to include(config.runame)
        expect(headers['X-EBAY-API-CALL-NAME']).to eq('GetSessionID')
        valid_session
      end
    end

    it "gets a session" do
      session = Ebay::Api.session
      expect(RestClient).to have_received(:post)
      expect(session.valid?).to be_true
    end

  end

  describe ".sign_in_url" do

    let(:session) { Ebay::Session.new(valid_session) }

    it "is a valid URI" do
      url = Ebay::Api.sign_in_url(session)
      uri = URI.parse(url)
      # expect no errors raised
    end

    it "contains configured runame" do
      url = Ebay::Api.sign_in_url(session)
      uri = URI.parse(url)
      expect(uri.query).to include(config.runame)
    end

    it "contains encoded session.id" do
      url = Ebay::Api.sign_in_url(session)
      uri = URI.parse(url)
      expect(uri.query).to include(CGI.escape(session.id))
    end

  end

  describe ".token" do

    let(:session) { Ebay::Session.new(valid_session) }

    before(:each) do
      RestClient.stub(:post) do |url, data, headers|
        expect(url).to eq(config.api_url)
        expect(data).to include(session.id)
        expect(headers['X-EBAY-API-CALL-NAME']).to eq('FetchToken')
        valid_session
      end
    end

    it "gets a token" do
      token = Ebay::Api.token(session)
      expect(RestClient).to have_received(:post)
    end

  end

end
