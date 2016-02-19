class Entry < ActiveRecord::Base

  # validations
  validates_presence_of :company_name, :ticker, :event_name, :date, :speaker_name, :speaker_title, :wcount, :transcript
  validates :event_name, uniqueness: {:scope => [:speaker_name, :company_name]}
end
