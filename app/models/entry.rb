class Entry < ActiveRecord::Base
  
  belongs_to :user

  validates_presence_of :company_name, :ticker, :event_name, :date, :speaker_name, :wcount, :transcript
  validates :event_name, uniqueness: {:scope => [:speaker_name, :company_name, :user_id]}
end
