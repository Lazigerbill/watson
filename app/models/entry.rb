class Entry
  include Mongoid::Document
  field :first_name
  field :last_name
  field :input

  # validations
  validates_presence_of :input
end
