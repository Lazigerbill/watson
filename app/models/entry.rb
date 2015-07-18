class Entry
  include Mongoid::Document
  field :company_name
  field :event_name
  field :date


  # validations
  validates_presence_of :company_name
end
