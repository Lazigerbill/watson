FactoryGirl.define do
  factory :entry do
    sequence(:company_name) {|n| "John Smith#{n} Corp"}
    ticker 'AAA'
    event_name 'Smith'
    date '2000-01-01'
    sequence(:speaker_name)  {|n| "John Smith#{n}"}
    wcount '4000'
    transcript 'hello world'
  end
end
