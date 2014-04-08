module DBViewCTI
  module SQLGeneration
    module Migration
      class Base
        
        def initialize(class_name, options = {})
          @options = options
          @derived_class = class_name.constantize
          @base_class    = @derived_class.superclass
          @base_class_table    = @base_class.table_name
          @derived_class_table = DBViewCTI::Names.table_name(@derived_class)
          # we assume the foreign key is in the derived class
          @base_class_key = 'id'
          @derived_class_key = DBViewCTI::Names.foreign_key(@base_class)
          # columns in base class
          @base_class_columns = @base_class.column_names
          if @base_class.cti_derived_class?
            # base class is itself derived, so we remove the foreign key it holds to the higher
            # level class
            foreign_key = DBViewCTI::Names.foreign_key(@base_class.superclass)
            @base_class_columns = @base_class_columns - [ foreign_key ]
          end
          # columns in derived class
          # first, reset table name (it might have been changed to the view name by cti_derived_class)
          temp = @derived_class.table_name
          @derived_class.table_name = @derived_class_table
          @derived_class.reset_column_information
          @derived_class_columns = @derived_class.column_names
          # put back old table name (needed since the class might be used again in a next migration)
          @derived_class.table_name = temp
          @derived_class.reset_column_information
          # names
          @view_name    = DBViewCTI::Names.view_name(@derived_class)
          @trigger_name = DBViewCTI::Names.trigger_name(@derived_class)
          # column arrays for triggers
          @insert_base_class_columns = @base_class_columns - ['id']
          @insert_derived_class_columns = @derived_class_columns - ['id', @derived_class_key]
          @update_base_class_columns = explicit_columns(@base_class_columns) + ['updated_at']
          @update_derived_class_columns = @derived_class_columns - [ @derived_class_key ]
        end
        
        def create_view_sql
          base_columns = add_table_name( explicit_columns(@base_class_columns), @base_class_table).
                         join(', ')
          derived_columns = add_table_name( @derived_class_columns - ['id', @derived_class_key], @derived_class_table).
                            join(', ')
          query = <<-eos
            CREATE VIEW #{@view_name} AS
            SELECT #{@derived_class_table}.id, #{base_columns}, #{derived_columns}
            FROM #{@base_class_table}
            INNER JOIN #{@derived_class_table} 
            ON #{ add_table_name(@base_class_key, @base_class_table) } = #{ add_table_name(@derived_class_key, @derived_class_table) };
          eos
        end
        
        def drop_view_sql
          "DROP VIEW #{@view_name};"
        end
        
        def view_exists_sql
          raise NotImplementedError, "DBViewCTI: view_exists_sql not implemented for this adapter."
        end

        def create_trigger_sql
          # to be implemented by derived classes
          raise NotImplementedError, "DBViewCTI: create_trigger_sql not implemented for this adapter."
        end
        
        def drop_trigger_sql
          # to be implemented by derived classes
          raise NotImplementedError, "DBViewCTI: drop_trigger_sql not implemented for this adapter."
        end
        
        private
        
          def explicit_columns(columns)
            columns - ['id', 'created_at', 'updated_at']
          end
          
          def add_table_name(columns, table_name)
            return table_name + '.' + columns if columns.is_a?(String)
            columns.map do |column|
              table_name + '.' + column
            end
          end
        
          def update_notation(columns, source_table)
            columns.map do |column|
              "#{column}=#{source_table}.#{column}"
            end.join(', ')
          end
        
      end
    end
  end
end