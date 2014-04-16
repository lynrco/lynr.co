require './lib/lynr/config'

shared_context "spec/support/ConfigHelper" do

  def stub_config(type, values)
    @_config ||= {}
    @_config[type] ||= {}
    @_config[type] = @_config[type].merge(values)
  end

  def stubbed_config(type)
    @_config ||= {}
    @_config.fetch(type, {})
  end

  before(:each) do
    Lynr.stub(:config) do |type, defaults|
      defaults ||= {}
      Lynr::Config.new(type, Lynr.env, stubbed_config(type).merge(defaults))
    end
  end

end
