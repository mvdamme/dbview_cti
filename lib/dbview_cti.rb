module DBViewCTI
  extend ActiveSupport::Autoload
  autoload :Names

  module ConnectionAdapters
    extend ActiveSupport::Autoload
    autoload :SchemaStatements
  end

  module Migration
    extend ActiveSupport::Autoload
    autoload :CommandRecorder
  end

  module SQLGeneration
    module Migration
      extend ActiveSupport::Autoload
      autoload :Factory
      autoload :Base
      autoload :PostgreSQL, 'db_view_cti/sql_generation/migration/postgresql'
    end
    extend ActiveSupport::Autoload
    autoload :Model
  end
  
  module Model
    extend ActiveSupport::Autoload
    autoload :CTI
    autoload :Extensions
  end
end

require 'db_view_cti/loader'
require 'db_view_cti/railtie' if defined?(Rails)

