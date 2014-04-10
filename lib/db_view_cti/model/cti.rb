module DBViewCTI
  module Model
    module CTI
      extend ActiveSupport::Concern
      
      include Hierarchy
      include TypeConversion
      include Destroy
      include SQL
      include Associations
      include AssociationValidations
    end
  end
end
