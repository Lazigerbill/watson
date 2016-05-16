FactoryGirl.define do
  factory :report do
    sequence(:id) {|n| "#{n}"}
    created_at '2016-03-03 20:07:34.675072'
    updated_at '2016-03-03 20:07:34.675072'
    company_name 'John Smith Corp'
    ticker 'AAA'
    speaker_name 'John Smith'
    speaker_title 'CEO'
    wcount '4000'
    user_id '1'
    combined_transcripts 'hello world'
    watson '"{"id":"*UNKNOWN*","source":"*UNKNOWN*","word_count":4000,"processed_lang":"en","tree":{"id":"r","name":"root","children":[{"id":"personality","name":"Big 5","children":[{"id":"Agreeableness_parent","name":"Agreeableness","category":"personality","percentag (...)"'
  end
end
