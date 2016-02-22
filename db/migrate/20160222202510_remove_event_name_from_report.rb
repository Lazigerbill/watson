class RemoveEventNameFromReport < ActiveRecord::Migration
  def change
    remove_column :reports, :event_name
  end
end
