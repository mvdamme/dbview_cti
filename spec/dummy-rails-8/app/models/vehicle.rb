class Vehicle < ActiveRecord::Base
  attr_accessible :name, :mass unless Rails::VERSION::MAJOR > 3
  cti_base_class
  
  validates :name, :presence => true  
  validate do |vehicle|
    errors.add(:base, "Block validation failed: name can't be blank") if vehicle.name.blank?
  end
end