class Car < MotorVehicle
  attr_accessible :stick_shift, :convertible, :vehicle_id unless Rails::VERSION::MAJOR > 3
  cti_derived_class
end
