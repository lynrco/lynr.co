require 'rspec/autorun'
require './lib/quicklist/model/image'

describe Quicklist::Model::Image do

  before(:all) do
    @url = "//quicklist.it/assets/image.gif"
    @image = Quicklist::Model::Image.new(300, 150, @url)
  end

  it "converts strings to integers when created" do
    image = Quicklist::Model::Image.new("300", "150", @url)
    image.width.should be(300)
    image.width.should_not be("300")
    image.height.should be(150)
    image.height.should_not be("150")
    image.should == @image
  end

  it "has a view with necessary data" do
    view = @image.view
    view.keys.should include(:width, :height, :url)
    view.values.should include(300, 150, @url)
  end

end
