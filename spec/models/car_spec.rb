# Since the gem provides model methods these tests serve as a kind of 'integration tests' for the gem
require 'spec_helper'

describe Car do
  before :each do
    @car = Car.create(:name => 'MyCar', :mass => 1000, :number_of_wheels => 4, :stick_shift => true)
  end
  
  it "creates parent-class records on create" do
    expect(Vehicle.count).to eq 1
    expect(MotorVehicle.count).to eq 1
    expect(Car.count).to eq 1
    expect(MotorCycle.count).to eq 0
  end

  it "updates properties of ancestor classes" do
    id = @car.id
    @car.name = 'Porsche'
    @car.fuel = 'gasoline'
    @car.convertible = true
    @car.bogus_field = 'bogus'
    @car.save!
    car = Car.find(id)
    expect(car.name).to eq 'Porsche'
    expect(car.mass).to eq 1000
    expect(car.fuel).to eq 'gasoline'
    expect(car.bogus_field).to eq 'bogus'
    expect(car.stick_shift).to be_truthy
    expect(car.convertible).to be_truthy
  end
  
  it "deletes parent-class records on destroy" do
    @car.destroy
    expect(Vehicle.count).to eq 0
    expect(MotorVehicle.count).to eq 0
    expect(Car.count).to eq 0
  end
  
  it "converts to parent classes" do
    motor_vehicle = @car.convert_to(:motor_vehicle)
    expect(motor_vehicle.class.name).to eq 'MotorVehicle'
    expect(motor_vehicle.specialize.id).to eq @car.id
    vehicle = @car.convert_to(:vehicle)
    expect(vehicle.class.name).to eq 'Vehicle'
    expect(vehicle.specialize.id).to eq @car.id
  end
  
  it "doesn't convert to non-parent class" do
    expect(@car.convert_to(:motor_cycle)).to be_nil
  end
  
  it "correctly reports ascendants" do
    expect(Car.cti_ascendants).to eq %w( Vehicle MotorVehicle ) 
  end
  
  it "correctly reports descendants" do
    expect(Car.cti_all_descendants).to eq [] 
  end
  
end
