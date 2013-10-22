class SpaceShip < Vehicle
  attr_accessible :single_use, :reliability unless Rails::VERSION::MAJOR > 3
  cti_derived_class
  
  has_many :launches
  has_one :captain
  has_and_belongs_to_many :astronauts, :join_table => 'astronauts_space_ships'
  has_many :experiment_space_ship_performances
  has_many :experiments, :through => :experiment_space_ship_performances
end
