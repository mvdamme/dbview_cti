class CheckViewExists < ActiveRecord::Migration
  def up
    raise 'View should exist!' if !cti_view_exists?('Car')
  end
  
  def down
  end
end
