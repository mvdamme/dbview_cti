module DBViewCTI
  module Model
    module CTI
      extend ActiveSupport::Concern
      
      def specialize
        class_name, id = type(true)
        return self if class_name == self.class.name
        class_name.constantize.find(id)
      end
      
      # Return the 'true' (i.e. most specialized) classname of this object
      # When return_id is true, the 'specialized' database id is also returned
      def type(return_id = false)
        query, levels = self.class.cti_outer_join_sql(id)
        result = self.class.connection.execute(query).first
        # replace returned ids with the levels corresponding to their classes
        result_levels = result.inject({}) do |hash, (k,v)|
          hash[k] = levels[k] unless v.nil?
          hash
        end
        # find class with maximum level value
        foreign_key = result_levels.max_by { |k,v| v }.first
        class_name = DBViewCTI::Names.table_to_class_name(foreign_key[0..-4])
        if return_id
          id_ = result[foreign_key].to_i
          [class_name, id_]
        else
          class_name
        end
      end
      
      def convert_to(type)
        type_string = type.to_s
        type_string = type_string.camelize if type.is_a?(Symbol)
        return self if type_string == self.class.name
        query = self.class.cti_inner_join_sql(id, type_string)
        # query is nil when we try to cenvert to an descendant class (instead of an ascendant),
        # or when we try to convert to a class outside of the hierarchy
        if query.nil?
          specialized = specialize
          return nil if specialized == self
          return specialized.convert_to(type_string)
        end
        result = self.class.connection.execute(query).first
        id = result[ DBViewCTI::Names.foreign_key(type.to_s) ]
        return nil if id.nil?
        type_string.constantize.find(id.to_i)
      end
      
      # change destroy and delete methods to operate on most specialized obect
      included do
        alias_method_chain :destroy, :specialize
        alias_method_chain :delete, :specialize
        # destroy! seems te be defined in Rails 4
        alias_method_chain :destroy!, :specialize if self.method_defined?(:destroy!) 
      end
      
      def destroy_with_specialize
        specialize.destroy_without_specialize
      end
      
      def destroy_with_specialize!
        specialize.destroy_without_specialize!
      end
      
      def delete_with_specialize
        specialize.delete_without_specialize
      end
      
      module ClassMethods
        
        def cti_base_class?
          !!@cti_base_class
        end
  
        def cti_derived_class?
          !!@cti_derived_class
        end
        
        attr_accessor :cti_descendants, :cti_ascendants
        
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
        
        include DBViewCTI::SQLGeneration::Model
        
        # this method is only used in testing. It returns the number of rows present in the real database
        # table, not the number of rows present in the view (as returned by count)
        def cti_table_count
          result = connection.execute("SELECT COUNT(*) FROM #{DBViewCTI::Names.table_name(self)};")
          result[0]['count'].to_i
        end
        
      end
    end
  end
end
