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
        classes = [ class_name ] + klass.cti_all_descendants
        # drop all views in reverse order
        classes.reverse.each do |kklass|
          cti_drop_view(kklass, options)
        end
        yield # perform table changes in block (e.g. add column)
        # recreate views in forward order
        classes.each do |kklass|
          # any column changes are reflected in the real table cache, but not in the
          # view cache, so we have to make sure it is cleared
          true_klass = kklass.constantize
          true_klass.connection.schema_cache.clear_table_cache!(true_klass.table_name) 
          true_klass.reset_column_information 
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

    end
  end
end

