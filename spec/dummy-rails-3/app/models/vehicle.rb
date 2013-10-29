class Vehicle < ActiveRecord::Base
  attr_accessible :name, :mass unless Rails::VERSION::MAJOR > 3
  cti_base_class
  
  validates :name, :presence => true  
end
