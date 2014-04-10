module DBViewCTI
  module Model
    module CTI
      module SQL
        extend ActiveSupport::Concern

        module ClassMethods

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
end