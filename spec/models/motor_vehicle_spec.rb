# Since the gem provides model methods these tests serve as a kind of 'integration tests' for the gem
require 'spec_helper'

describe MotorVehicle do

  it "correctly specializes to the derived class" do
    @car = Car.create(:name => 'MyCar')
    motor_vehicle = MotorVehicle.order(:id).last
    car = motor_vehicle.specialize
    expect(car.class.name).to eq 'Car'
    expect(car.id).to eq @car.id
     
    @motorcycle = MotorCycle.create(:name => 'MyBike')
    motor_vehicle = MotorVehicle.order(:id).last
    motorcycle = motor_vehicle.specialize
    expect(motorcycle.class.name).to eq 'MotorCycle'
    expect(motorcycle.id).to eq @motorcycle.id
  end

  it "correctly converts to the derived classes" do
    @car = Car.create(:name => 'MyCar')
    # convert to parent
    motor_vehicle = @car.convert_to(:motor_vehicle)
    # convert back to derived class
    car = motor_vehicle.convert_to(:car)
    expect(car.class.name).to eq 'Car'
    expect(car.id).to eq @car.id
  end

  it "doesn't convert to class outside of hierarchy" do
    @car = Car.create(:name => 'MyCar')
    motor_vehicle = @car.convert_to(:motor_vehicle)
    expect(motor_vehicle.convert_to(:rocket_engine)).to be_nil
  end

  it "correctly reports ascendants" do
    expect(MotorVehicle.cti_ascendants).to eq %w( Vehicle ) 
  end
  
  it "correctly reports descendants" do
    expect(MotorVehicle.cti_all_descendants).to eq %w( Car MotorCycle )
  end
  
end
