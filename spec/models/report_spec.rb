require 'rails_helper'

describe Report do
  it 'is valid with id, created_at and updated_at timestamps, company_name, ticker, speaker_name
      speaker_title, wcount, user_id, combined_transcript, and watson' do
    expect(build(:report)).to be_valid
  end
end
