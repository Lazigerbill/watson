class AddColTranscriptToReport < ActiveRecord::Migration
  def change
    add_column :reports, :transcript, :text
  end
end
