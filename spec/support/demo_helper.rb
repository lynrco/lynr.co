shared_context "spec/support/DemoHelper" do
  shared_context "features.demo=true" do
    before(:all) do
      stub_config('features', 'demo' => 'true')
    end
    after(:all) do
      stub_config('features', 'demo' => 'false')
    end
  end
end
