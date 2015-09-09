class User
  include Mongoid::Document
  field :username
  field :email
  field :password

  
  authenticates_with_sorcery!
  validates_presence_of :username, :email, :password, :password_confirmation
  validates :email, uniqueness: true
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes["password"] }
  validates :password, confirmation: true, if: -> { new_record? || changes["password"] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes["password"] }
end
