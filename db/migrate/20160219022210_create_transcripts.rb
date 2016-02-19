class CreateTranscripts < ActiveRecord::Migration
  def change
    create_table :transcripts do |t|
      t.string :company_name
      t.string :ticker
      t.string :event_name
      t.date :date
      t.string :speaker_name
      t.string :speaker_title
      t.integer :wcount
      t.text :transcript
      t.json :insights

      t.timestamps null: false
    end
  end
end
