module DBViewCTI
  module Model
    module CTI
      module Destroy
        extend ActiveSupport::Concern

        # change destroy and delete methods to operate on most specialized object
        included do
          alias_method_chain :destroy, :cti
          alias_method_chain :delete, :cti
          # destroy! seems te be defined in Rails 4
          alias_method_chain :destroy!, :cti if self.method_defined?(:destroy!)
        end
        
        def destroy_with_cti
          specialize.destroy_without_cti
        end
        
        def destroy_with_cti!
          specialize.destroy_without_cti!
        end
        
        def delete_with_cti
          specialize.delete_without_cti
        end
        
      end
    end
  end
end