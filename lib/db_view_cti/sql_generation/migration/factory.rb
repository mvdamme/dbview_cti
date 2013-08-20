module DBViewCTI
  module SQLGeneration
    module Migration
      class Factory
        
        def self.generator(class_name, options = {})
          adapter_type = ActiveRecord::Base.configurations[Rails.env]['adapter']
          case adapter_type
          when /postgresql/
            PostgreSQL.new(class_name, options)
          else
            raise NotImplementedError, "DBViewCTI: Unknown adapter type '#{adapter_type}'"
          end        
        end
        
      end
    end
  end
end