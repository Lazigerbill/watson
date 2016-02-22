class EditReports < ActiveRecord::Migration
  def change
    remove_column :reports, :transcript, :text
    remove_column :reports, :combined_transcripts, :string
    add_column :reports, :combined_transcripts, :text
  end
end
