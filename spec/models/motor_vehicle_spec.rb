# Since the gem provides model methods these tests serve as a kind of 'integration tests' for the gem
require 'spec_helper'

describe MotorVehicle do

  it "correctly specializes to the derived class" do
    @car = Car.create(:name => 'MyCar')
    motor_vehicle = MotorVehicle.order(:id).last
    car = motor_vehicle.specialize
    car.class.name.should eq 'Car'
    car.id.should eq @car.id
     
    @motorcycle = MotorCycle.create(:name => 'MyBike')
    motor_vehicle = MotorVehicle.order(:id).last
    motorcycle = motor_vehicle.specialize
    motorcycle.class.name.should eq 'MotorCycle'
    motorcycle.id.should eq @motorcycle.id
  end

  it "correctly converts to the derived classes" do
    @car = Car.create(:name => 'MyCar')
    # convert to parent
    motor_vehicle = @car.convert_to(:motor_vehicle)
    # convert back to derived class
    car = motor_vehicle.convert_to(:car)
    car.class.name.should eq 'Car'
    car.id.should eq @car.id
  end

  it "doesn't convert to class outside of hierarchy" do
    @car = Car.create(:name => 'MyCar')
    motor_vehicle = @car.convert_to(:motor_vehicle)
    motor_vehicle.convert_to(:rocket_engine).should be_nil
  end

  it "correctly reports ascendants" do
    MotorVehicle.cti_ascendants.should eq %w( Vehicle ) 
  end
  
  it "correctly reports descendants" do
    MotorVehicle.cti_all_descendants.should eq %w( Car MotorCycle )
  end
  
end
