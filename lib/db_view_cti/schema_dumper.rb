# this file is inspired by schema_dumper.rb in the foreigner gem 
# ( https://github.com/matthuhiggins/foreigner )
module DBViewCTI
  module SchemaDumper
    extend ActiveSupport::Concern

    included do
      alias_method_chain :tables, :cti_views
    end

    def tables_with_cti_views(stream)
      tables_without_cti_views(stream)
      base_classes = []
      @connection.tables.sort.each do |table|
        next if ignore_table?(table)
        begin
          klass = DBViewCTI::Names.table_to_class_name(table).constantize
          base_classes << klass if klass.respond_to?('cti_base_class?') && klass.cti_base_class?
        rescue NameError
          # do nothing
        end
      end
      base_classes.each do |klass|
        dump_cti_hierarchy(klass, stream)
      end
    end

    private
    
      def ignore_table?(table)
        ['schema_migrations', ignore_tables].flatten.any? do |ignored|
          case ignored
          when String; table == ignored
          when Regexp; table =~ ignored
          else
            raise StandardError, 'ActiveRecord::SchemaDumper.ignore_tables accepts an array of String and / or Regexp values.'
          end
        end
      end
      
      def dump_cti_hierarchy(base_class, stream)
        base_class.cti_all_descendants.each do |class_name|
          stream.puts("  cti_create_view('#{class_name}')")
        end
        stream.puts('')
      end
    
  end
end
