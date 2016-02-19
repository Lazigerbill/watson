class RenameTable < ActiveRecord::Migration
  def change
    rename_table :transcripts, :entries
  end
end
