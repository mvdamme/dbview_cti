# Since the gem provides model methods these tests serve as a kind of 'integration tests' for the gem
require 'spec_helper'

describe Vehicle do
  
  it "correctly specializes to the derived class" do
    @car = Car.create(:name => 'MyCar')
    vehicle = Vehicle.order(:id).last
    car = vehicle.specialize
    car.class.name.should eq 'Car'
    car.id.should eq @car.id
     
    @motorcycle = MotorCycle.create(:name => 'MyBike')
    vehicle = Vehicle.order(:id).last
    motorcycle = vehicle.specialize
    motorcycle.class.name.should eq 'MotorCycle'
    motorcycle.id.should eq @motorcycle.id
     
    @motor_vehicle = MotorVehicle.create(:name => 'MyTrike')
    vehicle = Vehicle.order(:id).last
    motor_vehicle = vehicle.specialize
    motor_vehicle.class.name.should eq 'MotorVehicle'
    motor_vehicle.id.should eq @motor_vehicle.id 
  end
  
  it "returns the correct type" do
    @car = Car.create(:name => 'MyCar')
    vehicle = Vehicle.order(:id).last
    vehicle.type.should eq 'Car'
     
    @motorcycle = MotorCycle.create(:name => 'MyBike')
    vehicle = Vehicle.order(:id).last
    vehicle.type.should eq 'MotorCycle'
     
    @motor_vehicle = MotorVehicle.create(:name => 'MyTrike')
    vehicle = Vehicle.order(:id).last
    vehicle.type.should eq 'MotorVehicle'
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
    Vehicle.count.should eq 1
    Car.cti_table_count.should eq 1
    MotorVehicle.cti_table_count.should eq 1
    vehicle = Vehicle.order(:id).last
    vehicle.send(method)
    Vehicle.count.should eq 0
    Car.cti_table_count.should eq 0
    MotorVehicle.cti_table_count.should eq 0
    # do the same for the space-branch (which has foreign key constraints)
    shuttle = SpaceShuttle.create(:name => 'Discovery')
    Vehicle.count.should eq 1
    SpaceShuttle.cti_table_count.should eq 1
    SpaceShip.cti_table_count.should eq 1
    vehicle = Vehicle.order(:id).last
    vehicle.send(method)
    Vehicle.count.should eq 0
    SpaceShuttle.cti_table_count.should eq 0
    SpaceShip.cti_table_count.should eq 0
  end
  
  # simply to show that the gem doesn't interfere with foreign keys
  it "raises an exception on foreign key violation" do
    shuttle = SpaceShuttle.create(:name => 'Discovery')
    expect {
      Vehicle.delete_all
    }.to raise_error
  end
  
  it "correctly reports ascendants" do
    Vehicle.cti_ascendants.should eq [] 
  end
  
  it "correctly reports descendants" do
    Vehicle.cti_all_descendants.should eq %w( MotorVehicle Car MotorCycle SpaceShip SpaceShuttle )
  end
  
end
