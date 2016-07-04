require 'rails_helper'

describe Entry do
  it 'is valid with company_name, ticker, event_name, date, speaker_name, wcount, and transcript' do
    expect(build(:entry)).to be_valid
  end

  it 'is invalid with missing company_name' do
    entry = build(:entry, company_name: nil)
    entry.valid?
    expect(entry.errors[:company_name]).to include("can't be blank")
  end


  it 'is invalid with missing ticker' do
    entry = build(:entry, ticker: nil)
    entry.valid?
    expect(entry.errors[:ticker]).to include("can't be blank")
  end


  it 'is invalid with missing event_name' do
    entry = build(:entry, event_name: nil)
    entry.valid?
    expect(entry.errors[:event_name]).to include("can't be blank")
  end


  it 'is invalid with missing date' do
    entry = build(:entry, date: nil)
    entry.valid?
    expect(entry.errors[:date]).to include("can't be blank")
  end

  it 'is invalid with missing speaker_name' do
    entry = build(:entry, speaker_name: nil)
    entry.valid?
    expect(entry.errors[:speaker_name]).to include("can't be blank")
  end

  it 'is invalid with missing wcount' do
    entry = build(:entry, wcount: nil)
    entry.valid?
    expect(entry.errors[:wcount]).to include("can't be blank")
  end

  it 'is invalid with missing transcript' do
    entry = build(:entry, transcript: nil)
    entry.valid?
    expect(entry.errors[:transcript]).to include("can't be blank")
  end

  it 'is invalid with same speaker_name, company_name, and user_id for one event' do
    create(:entry, speaker_name: 'John Smith', company_name: 'JSmith Corp', user_id: '1')
    entry = build(:entry, speaker_name: 'John Smith', company_name: 'JSmith Corp', user_id: '1')
    entry.valid?
    expect(entry.errors[:event_name]).to include("has already been taken")
  end

  it 'is valid with same speaker_name and company_name but different user_id for one event' do
    create(:entry, speaker_name: 'John Smith', company_name: 'JSmith Corp', user_id: '1')
    entry = build(:entry, speaker_name: 'John Smith', company_name: 'JSmith Corp', user_id: '2')
    expect(entry).to be_valid
  end

  it 'is valid with same speaker_name and user_id but different company_name for one event' do
    create(:entry, speaker_name: 'John Smith', company_name: 'JSmith Corp', user_id: '1')
    entry = build(:entry, speaker_name: 'John Smith', company_name: 'JSmith Corp 2', user_id: '1')
    expect(entry).to be_valid
  end

  it 'is valid with same company_name and user_id but different speaker_name for one event' do
    create(:entry, speaker_name: 'John Smith', company_name: 'JSmith Corp', user_id: '1')
    entry = build(:entry, speaker_name: 'John Smith 2', company_name: 'JSmith Corp', user_id: '1')
    expect(entry).to be_valid
  end
end
