class Entry
  include Mongoid::Document
  field :company_name
  field :event_name
  field :date
  field :speaker
  field :transcript

  # validations
  validates_presence_of :company_name, :event_name, :date, :speaker, :transcript
end
