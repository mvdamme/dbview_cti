# Since the gem provides model methods these tests serve as a kind of 'integration tests' for the gem
require 'spec_helper'

describe Vehicle do
  
  it "correctly specializes to the derived class" do
    @car = Car.create(:name => 'MyCar')
    vehicle = Vehicle.order(:id).last
    car = vehicle.specialize
    expect(car.class.name).to eq 'Car'
    expect(car.id).to eq @car.id
     
    @motorcycle = MotorCycle.create(:name => 'MyBike')
    vehicle = Vehicle.order(:id).last
    motorcycle = vehicle.specialize
    expect(motorcycle.class.name).to eq 'MotorCycle'
    expect(motorcycle.id).to eq @motorcycle.id
     
    @motor_vehicle = MotorVehicle.create(:name => 'MyTrike')
    vehicle = Vehicle.order(:id).last
    motor_vehicle = vehicle.specialize
    expect(motor_vehicle.class.name).to eq 'MotorVehicle'
    expect(motor_vehicle.id).to eq @motor_vehicle.id 
  end
  
  it "returns the correct type" do
    @car = Car.create(:name => 'MyCar')
    vehicle = Vehicle.order(:id).last
    expect(vehicle.type).to eq 'Car'
     
    @motorcycle = MotorCycle.create(:name => 'MyBike')
    vehicle = Vehicle.order(:id).last
    expect(vehicle.type).to eq 'MotorCycle'
     
    @motor_vehicle = MotorVehicle.create(:name => 'MyTrike')
    vehicle = Vehicle.order(:id).last
    expect(vehicle.type).to eq 'MotorVehicle'
  end
  
  it "also destroys rows belonging to derived classes on destroy" do
    test_destroy_variant(:destroy)
  end
  
  it "also destroys rows belonging to derived classes on delete" do
    test_destroy_variant(:delete)
  end
  
  it "also destroys rows belonging to derived classes on destroy!" do
    test_destroy_variant(:destroy!) if Vehicle.method_defined?(:destroy!)
  end
  
  def test_destroy_variant(method)
    car = Car.create(:name => 'MyCar')
    expect(Vehicle.count).to eq 1
    expect(Car.cti_table_count).to eq 1
    expect(MotorVehicle.cti_table_count).to eq 1
    vehicle = Vehicle.order(:id).last
    vehicle.send(method)
    expect(Vehicle.count).to eq 0
    expect(Car.cti_table_count).to eq 0
    expect(MotorVehicle.cti_table_count).to eq 0
    # do the same for the space-branch (which has foreign key constraints)
    shuttle = SpaceShuttle.create(:name => 'Discovery')
    expect(Vehicle.count).to eq 1
    expect(SpaceShuttle.cti_table_count).to eq 1
    expect(SpaceShip.cti_table_count).to eq 1
    vehicle = Vehicle.order(:id).last
    vehicle.send(method)
    expect(Vehicle.count).to eq 0
    expect(SpaceShuttle.cti_table_count).to eq 0
    expect(SpaceShip.cti_table_count).to eq 0
  end
  
  # simply to show that the gem doesn't interfere with foreign keys
  it "raises an exception on foreign key violation" do
    shuttle = SpaceShuttle.create(:name => 'Discovery')
    expect {
      Vehicle.delete_all
    }.to raise_error(ActiveRecord::InvalidForeignKey)
  end
  
  it "correctly reports ascendants" do
    expect(Vehicle.cti_ascendants).to eq [] 
  end
  
  it "correctly reports descendants" do
    expect(Vehicle.cti_all_descendants).to eq %w( MotorVehicle Car MotorCycle SpaceShip SpaceShuttle )
  end
  
end
