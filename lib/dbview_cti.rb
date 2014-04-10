ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym('CTI')
  inflect.acronym('CTIs')
end

module DBViewCTI
  extend ActiveSupport::Autoload
  autoload :Names
  autoload :SchemaDumper

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
    autoload :ModelDelegator
    autoload :CollectionDelegator
    autoload :TypeConversion, 'db_view_cti/model/cti/type_conversion'
    autoload :Hierarchy, 'db_view_cti/model/cti/hierarchy'
    autoload :Destroy, 'db_view_cti/model/cti/destroy'
    autoload :SQL, 'db_view_cti/model/cti/sql'
    autoload :Associations, 'db_view_cti/model/cti/associations'
    autoload :AssociationValidations, 'db_view_cti/model/cti/association_validations'
  end
end

require 'db_view_cti/loader'
require 'db_view_cti/railtie' if defined?(Rails)

