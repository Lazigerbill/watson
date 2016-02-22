class AddColWatsonToReport < ActiveRecord::Migration
  def change
    add_column :reports, :watson, :json
  end
end
