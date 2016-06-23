class AddFailedEntriesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :failed_entries, :string
  end
end
