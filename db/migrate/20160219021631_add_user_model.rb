class AddUserModel < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :student_id
      t.string :email
      t.string :password
      t.string :reset_password_token, :default => nil
      t.datetime :reset_password_token_expires_at, :default => nil
      t.datetime :reset_password_email_sent_at, :default => nil
    end
  end
end

