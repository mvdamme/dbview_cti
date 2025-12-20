class SpaceShip < Vehicle
  attr_accessible :single_use, :reliability unless Rails::VERSION::MAJOR > 3
  cti_derived_class
  
  belongs_to :category, :optional => true

  has_many :launches
  accepts_nested_attributes_for :launches

  has_one :captain
  accepts_nested_attributes_for :captain
  
  has_and_belongs_to_many :astronauts, :join_table => 'astronauts_space_ships'
  accepts_nested_attributes_for :astronauts

  has_many :experiment_space_ship_performances
  has_many :experiments, :through => :experiment_space_ship_performances
  accepts_nested_attributes_for :experiments
  
  has_many :upgraded_to, :class_name => 'SpaceShuttle', :foreign_key => 'upgraded_from_id'
end
