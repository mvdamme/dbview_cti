class SpaceShip < Vehicle
  attr_accessible :single_use, :reliability unless Rails::VERSION::MAJOR > 3
  cti_derived_class
end
