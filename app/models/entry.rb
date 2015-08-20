class Entry
  include Mongoid::Document
  field :company_name
  field :ticker
  field :event_name
  field :date, type: DateTime
  field :speaker_name
  field :speaker_title
  field :wcount, type: Integer
  field :transcript
  field :insights, type: Hash

  # validations
  validates_presence_of :company_name, :event_name, :date, :speaker_name, :speaker_title, :transcript
end
