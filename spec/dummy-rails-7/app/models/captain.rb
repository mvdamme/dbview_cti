class Captain < ActiveRecord::Base
  attr_accessible :spache_ship_id, :name unless Rails::VERSION::MAJOR > 3
  
  belongs_to :space_ship, :optional => true
end
