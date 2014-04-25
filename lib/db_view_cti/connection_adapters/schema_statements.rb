module DBViewCTI
  module ConnectionAdapters
    module SchemaStatements

      def cti_create_view(class_name, options = {})
        generator = DBViewCTI::SQLGeneration::Migration::Factory.generator(class_name)
        cti_execute_sql(generator.create_view_sql)
        cti_execute_sql(generator.create_trigger_sql)
      end

      def cti_drop_view(class_name, options = {})
        generator = DBViewCTI::SQLGeneration::Migration::Factory.generator(class_name)
        cti_execute_sql(generator.drop_trigger_sql)
        cti_execute_sql(generator.drop_view_sql)
      end
      
      def cti_view_exists?(class_name)
        generator = DBViewCTI::SQLGeneration::Migration::Factory.generator(class_name)
        cti_execute_sql(generator.view_exists_sql)[0]['count'].to_i > 0
      end

      # use with block in up/down methods
      def cti_recreate_views_after_change_to(class_name, options = {})
        klass = class_name.constantize
        classes = klass.cti_all_descendants
        # only add class_name if it is not the base class
        classes = classes.unshift( class_name ) unless klass.cti_base_class?
        # drop all views in reverse order
        classes.reverse.each do |kklass|
          cti_drop_view(kklass, options)
        end
        yield # perform table changes in block (e.g. add column)
        # recreate views in forward order
        cti_reset_column_information(class_name) if klass.cti_base_class?
        classes.each do |kklass|
          cti_reset_column_information(kklass)
          cti_create_view(kklass, options)
        end
      end
      
      # Needed since sqlite only executes the first statement in a string containing multiple
      # statements
      def cti_execute_sql(sql)
        return execute(sql) if sql.is_a?(String)
        sql.map do |query|
          execute(query)
        end
      end
      
      private
      
        def cti_reset_column_information(class_name)
          # any column changes are reflected in the real table cache, but not in the
          # view cache, so we have to make sure it is cleared
          klass = class_name.constantize
          klass.connection.schema_cache.clear_table_cache!(klass.table_name) 
          klass.reset_column_information 
        end

    end
  end
end

