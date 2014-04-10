module DBViewCTI
  module Model
    module CTI
      module Hierarchy
        extend ActiveSupport::Concern

        module ClassMethods
          
          def cti_base_class?
            !!@cti_base_class
          end
    
          def cti_derived_class?
            !!@cti_derived_class
          end
          
          attr_accessor :cti_descendants, :cti_ascendants, :cti_association_proxies
          
          # registers a derived class and its descendants in the current class
          # class_name: name of derived class (the one calling cti_register_descendants on this class)
          # descendants: the descendants of the derived class
          def cti_register_descendants(class_name, descendants = {})
            @cti_descendants ||= {}
            @cti_descendants[class_name] = descendants
            if cti_derived_class?
              # call up the chain. This will also cause the register_ascendants callbacks
              self.superclass.cti_register_descendants(self.name, @cti_descendants)
            end
            # call back to calling class
            @cti_ascendants ||= []
            class_name.constantize.cti_register_ascendants(@cti_ascendants + [ self.name ])
          end
          
          # registers the ascendants of the current class. Called on this class by the parent class.
          # ascendants: array of ascendants. The first element is the highest level class, derived
          # classes follow, the last element is the parent of this class.
          def cti_register_ascendants(ascendants)
            @cti_ascendants = ascendants
          end
          
          # returns a list of all descendants
          def cti_all_descendants
            result = []
            block = Proc.new do |klass, descendants|
              result << klass
              descendants.each(&block)
            end
            @cti_descendants ||= {}
            @cti_descendants.each(&block)
            result
          end

        end

      end
    end
  end
end