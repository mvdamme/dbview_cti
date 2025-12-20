class Category < ActiveRecord::Base
  attr_accessible :name unless Rails::VERSION::MAJOR > 3
  has_many :space_ships
  validates :name, :presence => true
end
