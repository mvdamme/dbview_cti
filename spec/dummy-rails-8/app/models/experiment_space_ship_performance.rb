class ExperimentSpaceShipPerformance < ActiveRecord::Base
  attr_accessible :performed_at unless Rails::VERSION::MAJOR > 3
  
  belongs_to :experiment, :optional => true
  belongs_to :space_ship, :optional => true
end
