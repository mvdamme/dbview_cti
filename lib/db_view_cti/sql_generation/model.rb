module DBViewCTI
  module SQLGeneration
    module Model

      # generates left-outer-join query used in specialize and type
     def cti_outer_join_sql(id)
        if !@cti_outer_join_query.nil?
          return [@cti_outer_join_query + "#{id if id}", @cti_outer_join_levels]
        end
        start = "SELECT #{DBViewCTI::Names.table_name(self)}.id AS #{DBViewCTI::Names.foreign_key(self)}"
        end_  = "\nFROM #{DBViewCTI::Names.table_name(self)}"
        levels = { DBViewCTI::Names.foreign_key(self) => 0 }
        level = 1
        base_class = self
        block = Proc.new do |klass, descendants|
          start += ", #{DBViewCTI::Names.table_name(klass)}.id AS #{DBViewCTI::Names.foreign_key(klass)}"
          end_ += "\nLEFT OUTER JOIN #{DBViewCTI::Names.table_name(klass)} " +
                  "ON #{DBViewCTI::Names.table_name(klass)}.#{DBViewCTI::Names.foreign_key(base_class)} = " +
                  "#{DBViewCTI::Names.table_name(base_class)}.id"
          prev_base_class = base_class
          base_class = klass
          levels[DBViewCTI::Names.foreign_key(klass)] = level
          level += 1
          descendants.each(&block) 
          level -= 1
          base_class = prev_base_class
        end
        @cti_descendants ||= {}
        @cti_descendants.each(&block)
        @cti_outer_join_query = start + end_ + "\nWHERE #{DBViewCTI::Names.table_name(self)}.id = "
        @cti_outer_join_levels = levels
        [@cti_outer_join_query + "#{id if id}", @cti_outer_join_levels]
      end
      
      # generates inner-join query used in convert_to(target_class)
      def cti_inner_join_sql(id, target_class)
        if @cti_inner_join_query && @cti_inner_join_query[target_class]
          return @cti_inner_join_query[target_class] + "#{id if id}"
        end
        return nil if !@cti_ascendants.include?(target_class)
        query = "SELECT #{DBViewCTI::Names.table_name(target_class)}.id AS #{DBViewCTI::Names.foreign_key(target_class)}" +
                "\nFROM #{DBViewCTI::Names.table_name(self)}"
        base_class = self
        @cti_ascendants ||= []
        @cti_ascendants.reverse.each do |ascendant|
          query += "\nINNER JOIN #{DBViewCTI::Names.table_name(ascendant)} " +
                   "ON #{DBViewCTI::Names.table_name(base_class)}.#{DBViewCTI::Names.foreign_key(ascendant)} = " +
                   "#{DBViewCTI::Names.table_name(ascendant)}.id"
          break if ascendant == target_class
          base_class = ascendant
        end
        query += "\nWHERE #{DBViewCTI::Names.table_name(self)}.id = "
        @cti_inner_join_query ||= {}
        @cti_inner_join_query[target_class] = query
        query + "#{id if id}"
      end
      
    end
  end
end