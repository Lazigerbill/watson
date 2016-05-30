FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Smith'
    sequence(:student_id, (100000000..999999999).cycle) {|n| "#{n}"}
    sequence(:email) {|n| "JohnS#{n}@utoronto.ca"}
    password 'test_password'
    password_confirmation 'test_password'
  end
end
