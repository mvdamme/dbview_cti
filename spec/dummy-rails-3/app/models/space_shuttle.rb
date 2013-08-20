class SpaceShuttle < SpaceShip
  attr_accessible :single_use unless Rails::VERSION::MAJOR > 3
  cti_derived_class
end
