class Transcript < ActiveRecord::Base
  validates_presence_of :company_name, :ticker, :event_name, :date, :speaker_name, :speaker_title, :wcount, :transcript
  validates_uniqueness_of :event_name, :scope => :speaker_name, :scope => :company_name
end
