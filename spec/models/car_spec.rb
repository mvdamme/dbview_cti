# Since the gem provides model methods these tests serve as a kind of 'integration tests' for the gem
require 'spec_helper'

describe Car do
  before :each do
    @car = Car.create(:name => 'MyCar', :mass => 1000, :number_of_wheels => 4, :stick_shift => true)
  end
  
  it "creates parent-class records on create" do
    Vehicle.count.should eq 1
    MotorVehicle.count.should eq 1
    Car.count.should eq 1
    MotorCycle.count.should eq 0
  end

  it "updates properties of ancestor classes" do
    id = @car.id
    @car.name = 'Porsche'
    @car.fuel = 'gasoline'
    @car.convertible = true
    @car.bogus_field = 'bogus'
    @car.save!
    car = Car.find(id)
    car.name.should eq 'Porsche'
    car.mass.should eq 1000
    car.fuel.should eq 'gasoline'
    car.bogus_field.should eq 'bogus'
    car.stick_shift.should be_true
    car.convertible.should be_true
  end
  
  it "deletes parent-class records on destroy" do
    @car.destroy
    Vehicle.count.should eq 0
    MotorVehicle.count.should eq 0
    Car.count.should eq 0
  end
  
  it "converts to parent classes" do
    motor_vehicle = @car.convert_to(:motor_vehicle)
    motor_vehicle.class.name.should eq 'MotorVehicle'
    motor_vehicle.specialize.id.should eq @car.id
    vehicle = @car.convert_to(:vehicle)
    vehicle.class.name.should eq 'Vehicle'
    vehicle.specialize.id.should eq @car.id
  end
  
  it "doesn't convert to non-parent class" do
    @car.convert_to(:motor_cycle).should be_nil
  end
  
  it "correctly reports ascendants" do
    Car.cti_ascendants.should eq %w( Vehicle MotorVehicle ) 
  end
  
  it "correctly reports descendants" do
    Car.cti_all_descendants.should eq [] 
  end
  
end
