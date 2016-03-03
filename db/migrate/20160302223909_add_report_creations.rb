class AddReportCreations < ActiveRecord::Migration
  def change
    add_column :users, :report_creations, :integer, default: 0
  end
end
