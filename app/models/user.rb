class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_many :entries
  has_many :reports

  validates_presence_of :first_name, :last_name, :student_id, :email, :password, :password_confirmation
  validates :email, :student_id, uniqueness: true
  validates :student_id, numericality: { only_integer: true }, length: { minimum: 9 }
  validates :email, format: { with: /@[\S\.]*utoronto\.ca/ }
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes["password"] }
  validates :password, confirmation: true, if: -> { new_record? || changes["password"] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes["password"] }

end

