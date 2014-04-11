class SpaceShuttle < SpaceShip
  attr_accessible :single_use unless Rails::VERSION::MAJOR > 3
  
  belongs_to :upgraded_from, :class_name => 'SpaceShip'

  # cti_derived_class has to come after te above belongs_to, otherwise the association will not work correctly.
  # This is only because SpaceShuttle is a leaf class (i.e. had no descendants).
  cti_derived_class
end
