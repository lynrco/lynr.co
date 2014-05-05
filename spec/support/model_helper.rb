require './lib/lynr/model/dealership'
require './lib/lynr/model/identity'
require './lib/lynr/model/vehicle'
require './lib/lynr/model/vin'

shared_context "spec/support/ModelHelper" do

  let(:identity) { Lynr::Model::Identity.new('bryan@lynr.co', 'this is a fake password') }
  let(:empty_dealership) {
    Lynr::Model::Dealership.new({ 'identity' => identity, 'customer_id' => mock_customer.id, })
  }
  let(:saved_empty_dealership) { subject.dealer_dao.save(empty_dealership) }
  let(:empty_vehicle) { Lynr::Model::Vehicle.new({ 'dealership' => saved_empty_dealership }) }
  let(:saved_empty_vehicle) { subject.vehicle_dao.save(empty_vehicle) }
  let(:vehicle_with_vin) {
    Lynr::Model::Vehicle.new({
      'dealership' => saved_empty_dealership,
      'vin' => vin_with_number
    })
  }
  let(:saved_vehicle_with_vin) { subject.vehicle_dao.save(vehicle_with_vin) }
  let(:vin_with_number) { Lynr::Model::Vin.new('number' => '1HGEJ6229XL063838') }
  let(:mock_customer) {
    Stripe::Customer.create({
      email: 'johnny@appleseed.com',
      card: StripeMock.generate_card_token(last4: "4242", exp_year: 2016),
    })
  }

  let(:demo_identity) { Lynr::Model::Identity.new('bryan@lynr.co', 'bryan@lynr.co') }
  let(:demo_dealership) {
    Lynr::Model::Dealership.new({ 'identity' => demo_identity, })
  }
  let(:saved_demo_dealership) { subject.dealer_dao.save(demo_dealership) }

end
