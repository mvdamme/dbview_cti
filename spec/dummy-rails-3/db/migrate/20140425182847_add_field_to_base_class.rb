class AddFieldToBaseClass < ActiveRecord::Migration
  def up
    # this makes cti_recreate_views_after_change_to also works for the base class
    cti_recreate_views_after_change_to('Vehicle') do
      add_column(:vehicles, :bogus_field, :string)
    end
  end

  def down
    cti_recreate_views_after_change_to('Vehicle') do
      remove_column(:vehicles, :bogus_field)
    end
  end
end
