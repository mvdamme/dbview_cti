require_relative './migration_helper'

class CheckViewExists < MigrationHelper.migration_base_class
  def up
    raise 'View should exist!' if !cti_view_exists?('Car')
  end
  
  def down
  end
end
