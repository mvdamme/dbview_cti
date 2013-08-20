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

