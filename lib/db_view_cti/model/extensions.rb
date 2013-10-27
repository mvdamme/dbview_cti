module DBViewCTI
  module Model
    module Extensions
      extend ActiveSupport::Concern
      
      module ClassMethods
        
        def cti_base_class
          self.class_eval { include(DBViewCTI::Model::CTI) }
          @cti_base_class = true
          cti_redefine_remote_associations
        end
  
        def cti_derived_class
          # there is no need to include DBViewCTI::Model::CTI in derived classes
          # (as we do in cti_base_class), since it is included in the base class
          # and we inherit from that  
          @cti_derived_class = true
          self.table_name = DBViewCTI::Names.view_name(self)
          self.superclass.cti_register_descendants(self.name)
          cti_create_association_proxies
          cti_redefine_remote_associations
          # call redefine_remote_associations on superclass to deal with associations
          # that were defined after the call to cti_derived_class or cti_base_class
          self.superclass.cti_redefine_remote_associations
        end
  
      end
    end
  end
end
