require 'rspec/autorun'
require './spec/spec_helper'

require './lib/lynr/persist/vehicle_dao'

require './lib/lynr/model/image'
require './lib/lynr/model/mpg'
require './lib/lynr/model/vin'

describe Lynr::Persist::VehicleDao do

  let(:dao) { Lynr::Persist::VehicleDao.new }

  let(:dealership_id) { BSON::ObjectId.new }
  let(:dealership) { Lynr::Model::Dealership.new({}, dealership_id) }

  let(:image) { Lynr::Model::Image.new("300", "150", "//lynr.co/assets/image.gif") }
  let(:mpg) { Lynr::Model::Mpg.new({ 'city' => 28.8, 'highway' => 33.2 }) }
  let(:vin) {
    Lynr::Model::Vin.new(
      'year'         => '2010',
      'make'         => 'Mitsubishi',
      'model'        => 'Gallant',
      'transmission' => "Manual",
      'fuel'         => "28 L",
      'doors'        => "2",
      'drivetrain'   => "AWD",
      'ext_color'    => "Silver",
      'int_color'    => "Charcoal"
    )
  }
  let(:vehicle_data) {
    {
      'year'       => '2010',
      'make'       => 'Mitsubishi',
      'model'      => 'Gallant',
      'price'      => 4999.99,
      'condition'  => 3,
      'mpg'        => mpg,
      'vin'        => vin,
      'images'     => [image],
      'dealership' => dealership
    }
  }

  before(:each) do
    dealership.stub(:id) { dealership_id }
  end

  context "with active connection", :if => (MongoHelpers.connected?) do

    let(:vehicle) { Lynr::Model::Vehicle.new(vehicle_data) }
    let(:saved) { dao.save(vehicle) }

    describe "#save" do

      it "returns a Vehicle instance" do
        expect(saved).to be_an_instance_of(Lynr::Model::Vehicle)
      end

      it "returns an instance with an id" do
        expect(vehicle.id).to be_nil
        expect(saved.id).to_not be_nil
      end

      it "returns instance with the same data" do
        expect(saved.year).to eq(vehicle_data['year'])
        expect(saved.make).to eq(vehicle_data['make'])
        expect(saved.model).to eq(vehicle_data['model'])
        expect(saved.price).to eq(vehicle_data['price'])
        expect(saved.condition).to eq(vehicle_data['condition'])
        expect(saved.mpg).to eq(vehicle_data['mpg'])
        expect(saved.vin).to eq(vehicle_data['vin'])
      end

    end # #save

    describe "#get" do

      let(:found) { dao.get(@id) }

      before(:each) do
        @id = saved.id
      end

      it "returns a vehicle instance" do
        expect(dao.get(@id)).to be_an_instance_of(Lynr::Model::Vehicle)
      end

      it "returns an instance with the correct id" do
        expect(found.id).to eq(@id)
        expect(found.id).to eq(saved.id)
      end

      it "returns an instance with the same data" do
        expect(found.year).to eq(saved.year)
        expect(found.make).to eq(saved.make)
        expect(found.model).to eq(saved.model)
        expect(found.price).to eq(saved.price)
        expect(found.condition).to eq(saved.condition)
        expect(found.mpg).to eq(saved.mpg)
        expect(found.vin).to eq(saved.vin)
      end

    end # #get

    describe "#list" do

      context "in DB with no records" do

        it "returns an empty collection when nothing saved" do
          expect(dao.list(dealership)).to be_empty
        end

      end

      context "in DB with 1 record" do

        before(:each) do
          @list_saved = dao.save(vehicle)
        end

        it "returns a non-empty collection when something saved" do
          expect(dao.list(dealership)).to_not be_empty
        end

        it "returns a collection of Vehicles" do
          dao.list(dealership).each do |item|
            expect(item).to be_an_instance_of(Lynr::Model::Vehicle)
          end
        end

        it "includes the saved record" do
          listed = dao.list(dealership)
          expect(dao.list(dealership)).to include(@list_saved)
        end

      end

    end # #list

  end

end
