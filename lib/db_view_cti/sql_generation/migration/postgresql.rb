module DBViewCTI
  module SQLGeneration
    module Migration
    
      class PostgreSQL < Base
        
        def create_trigger_sql
          # trigger function
          @trigger_func_name = DBViewCTI::Names.trigger_function_name(@derived_class)
  
          insert_trigger_func = <<-eos
            CREATE OR REPLACE FUNCTION #{trigger_func_name}()
            RETURNS TRIGGER
            LANGUAGE plpgsql
            AS $function$
              DECLARE
                base_id integer;
                derived_id integer;
                return_row RECORD;
              BEGIN
                IF TG_OP = 'INSERT' THEN
                  -- insert into base class and return id
                  INSERT INTO #{@base_class_table} (#{ @insert_base_class_columns.join(', ') })
                  VALUES (#{ add_table_name(@insert_base_class_columns, 'NEW').join(', ') })
                  RETURNING #{@base_class_key}
                  INTO base_id;
                  -- insert into derived class, including foreign key
                  INSERT INTO #{@derived_class_table} (#{ (@insert_derived_class_columns + [@derived_class_key]).join(', ') })
                  VALUES (#{ add_table_name(@insert_derived_class_columns, 'NEW').join(', ') },
                          base_id)
                  RETURNING id
                  INTO derived_id;
                  -- return correct record from view
                  SELECT * 
                  INTO return_row
                  FROM #{@view_name}
                  WHERE id = derived_id
                  LIMIT 1;
                  RETURN return_row;
  
                ELSIF TG_OP = 'UPDATE' THEN
                  -- update base class
                  UPDATE #{@base_class_table}
                  SET #{ update_notation(@update_base_class_columns, 'NEW') }
                  WHERE #{@base_class_table}.#{@base_class_key} = 
                        (SELECT #{@derived_class_key} FROM #{@derived_class_table}
                         WHERE #{@derived_class_table}.id = OLD.id); 
                  -- update derived class
                  UPDATE #{@derived_class_table}
                  SET #{ update_notation(@update_derived_class_columns, 'NEW') }
                  WHERE #{@derived_class_table}.id = OLD.id;
                  -- return correct record from view
                  SELECT * 
                  INTO return_row
                  FROM #{@view_name}
                  WHERE id = OLD.id
                  LIMIT 1;
                  RETURN return_row;
  
                ELSIF TG_OP = 'DELETE' THEN
                  -- find foreign key (not present in view!) in derived class
                  SELECT #{@derived_class_key}
                  INTO base_id
                  FROM #{@derived_class_table}
                  WHERE id = OLD.id;
                  -- due to possible key constraints we first delete the derived class
                  DELETE FROM #{@derived_class_table}
                  WHERE #{@derived_class_table}.id = OLD.id;
                  -- delete base class
                  DELETE FROM #{@base_class_table}
                  WHERE #{@base_class_table}.#{@base_class_key} = base_id;
                  RETURN NULL; 
                  
                END IF;
                RETURN NEW;
              END;          
            $function$;
          eos
  
          # trigger:
          insert_trigger = <<-eos
            CREATE TRIGGER #{@trigger_name}
            INSTEAD OF INSERT OR UPDATE OR DELETE ON #{@view_name}
            FOR EACH ROW
            EXECUTE PROCEDURE #{trigger_func_name}(); 
          eos
          insert_trigger_func + insert_trigger
        end
  
        def view_exists_sql
          "SELECT count(*) FROM pg_views where viewname='#{@view_name}';"
        end

        def drop_trigger_sql
          query = <<-eos
            DROP TRIGGER IF EXISTS #{@trigger_name} ON #{@view_name};
            DROP FUNCTION IF EXISTS #{trigger_func_name}();
          eos
        end
        
        private
        
          def trigger_func_name
            DBViewCTI::Names.trigger_function_name(@derived_class)
          end
        
      end
      
    end
  end
end