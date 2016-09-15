module DBViewCTI
  module Model
    module CTI
      module Destroy
        extend ActiveSupport::Concern

        # change destroy and delete methods to operate on most specialized object
        included do
          alias_method :destroy_without_cti, :destroy
          alias_method :destroy, :destroy_with_cti

          alias_method :delete_without_cti, :delete
          alias_method :delete, :delete_with_cti

          # destroy! seems te be defined in Rails 4
          if self.method_defined?(:destroy!)
            alias_method :destroy_without_cti!, :destroy!
            alias_method :destroy!, :destroy_with_cti!
          end
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