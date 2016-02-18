class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :first_name
  field :last_name
  field :student_id
  field :email
  field :password
  field :reset_password_token, :default => nil
  field :reset_password_token_expires_at, :type => DateTime, :default => nil
  field :reset_password_email_sent_at, :type => DateTime, :default => nil

  
  authenticates_with_sorcery!
  validates_presence_of :first_name, :last_name, :student_id, :email, :password, :password_confirmation
  validates :email, :student_id, uniqueness: true
  validates :email, format: { with: /.utoronto.ca/ }
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes["password"] }
  validates :password, confirmation: true, if: -> { new_record? || changes["password"] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes["password"] }
end

