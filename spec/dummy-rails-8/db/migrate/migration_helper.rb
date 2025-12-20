module MigrationHelper

  def self.migration_base_class
    klass = ActiveRecord::Migration

    if Rails::VERSION::MAJOR >= 5
      if Rails::VERSION::MAJOR > 5 || Rails::VERSION::MINOR >= 1
        klass = ActiveRecord::Migration[4.2]
      end
    end

    klass
  end

end