class AddColumnsToReports < ActiveRecord::Migration
  def change
    add_column :reports, :company_name, :string
    add_column :reports, :ticker, :string
    add_column :reports, :event_name, :string
    add_column :reports, :speaker_name, :string
    add_column :reports, :speaker_title, :string
    add_column :reports, :wcount, :integer
    add_column :reports, :combined_transcripts, :string
  end
end
