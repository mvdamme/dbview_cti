class MotorVehicle < Vehicle
  attr_accessible :fuel, :number_of_wheels unless Rails::VERSION::MAJOR > 3
  cti_derived_class
end
