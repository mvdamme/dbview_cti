module DBViewCTI
  module Model
    module CTI
      module TypeConversion

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
          return nil unless persisted?
          type_string = type.to_s
          type_string = type_string.camelize if type.is_a?(Symbol)
          return self if type_string == self.class.name
          query = self.class.cti_inner_join_sql(id, type_string)
          # query is nil when we try to cenvert to a descendant class (instead of an ascendant),
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
        
      end
    end
  end
end