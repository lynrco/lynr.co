require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/web'

describe Lynr::Web do

  describe '.title_for_code' do
    it { expect(Lynr::Web.title_for_code(403)).to eq('Unauthorized') }
    it { expect(Lynr::Web.title_for_code(404)).to eq('Not Found') }
    it { expect(Lynr::Web.title_for_code(500)).to eq('Wrecked') }
  end

  describe '.message_for_code' do
    it { expect(Lynr::Web.message_for_code(403)).to eq("You don't have permission to view this. Maybe you are signed into the wrong account, would you like to <a href=\"/signout\">sign out</a>?") }
    it { expect(Lynr::Web.message_for_code(404)).to eq("Why don't you try that again.") }
    it { expect(Lynr::Web.message_for_code(500)).to eq("We aren't sure what happend but have been notified and will look into it.") }
  end

end
