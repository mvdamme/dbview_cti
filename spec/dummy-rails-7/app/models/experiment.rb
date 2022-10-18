class Experiment < ActiveRecord::Base
  attr_accessible :name unless Rails::VERSION::MAJOR > 3

  has_many :experiment_space_ship_performances
  has_many :space_ships, :through => :experiment_space_ship_performances
end
