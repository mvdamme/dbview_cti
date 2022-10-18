module DBViewCTI
  module SQLGeneration
    module Migration
      class Factory
        
        def self.generator(class_name, options = {})
          adapter_type = if Rails::VERSION::MAJOR > 6 || ( Rails::VERSION::MAJOR == 6 && Rails::VERSION::MINOR >= 1)
            ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).first.adapter
          else
            ActiveRecord::Base.configurations[Rails.env]['adapter']
          end
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