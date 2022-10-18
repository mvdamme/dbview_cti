class MotorCycle < MotorVehicle
  attr_accessible :offroad unless Rails::VERSION::MAJOR > 3
  cti_derived_class
end
