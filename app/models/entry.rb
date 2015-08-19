class Entry
  include Mongoid::Document
  field :company_name
  field :event_name
  field :date, type: DateTime
  field :speaker_name
  field :speaker_title
  field :transcript
  field :insights, type: Hash

  # validations
  validates_presence_of :company_name, :event_name, :date, :speaker, :transcript, :wcount
end
