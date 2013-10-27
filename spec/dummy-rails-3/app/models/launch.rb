class Launch < ActiveRecord::Base
  attr_accessible :spache_ship_id, :date unless Rails::VERSION::MAJOR > 3

  belongs_to :space_ship
  
  validates :date, :presence => true
end
