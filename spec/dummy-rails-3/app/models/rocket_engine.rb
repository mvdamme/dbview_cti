class RocketEngine < ActiveRecord::Base
  attr_accessible :name, :space_ship_id unless Rails::VERSION::MAJOR > 3
  belongs_to :space_ship
end
