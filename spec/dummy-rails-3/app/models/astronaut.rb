class Astronaut < ActiveRecord::Base
  attr_accessible :name unless Rails::VERSION::MAJOR > 3
  
  has_and_belongs_to_many :space_ships, :join_table => 'astronauts_space_ships'
end
