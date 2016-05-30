require 'rails_helper'

describe User do
  it 'is valid with first_name, last_name, student_id, email, password, password_confirmation' do
    expect(build(:user)).to be_valid
  end

  it 'is invalid wtih no first_name' do
    user = build(:user, first_name: nil)
    user.valid?
    expect(user.errors[:first_name]).to include("can't be blank")
  end

  it 'is invalid wtih no last_name' do
    user = build(:user, last_name: nil)
    user.valid?
    expect(user.errors[:last_name]).to include("can't be blank")
  end

  it 'is invalid wtih no student_id' do
    user = build(:user, student_id: nil)
    user.valid?
    expect(user.errors[:student_id]).to include("can't be blank")
  end

  it 'is invalid wtih no email' do
    user = build(:user, email: nil)
    user.valid?
    expect(user.errors[:email]).to include("can't be blank")
  end

  it 'is invalid wtih no password' do
    user = build(:user, password: nil)
    user.valid?
    expect(user.errors[:password]).to include("can't be blank")
  end

  it 'is invalid wtih no password_confirmation' do
    user = build(:user, password_confirmation: nil)
    user.valid?
    expect(user.errors[:password_confirmation]).to include("can't be blank")
  end

  it 'is invalid with duplicate email' do
    create(:user, email: 'JSmith@utoronto.ca')
    user = build(:user, email: 'JSmith@utoronto.ca')
    user.valid?
    expect(user.errors[:email]).to include('has already been taken')
  end

  it 'is invalid with duplicate student_id' do
    create(:user, student_id: '123456789')
    user = build(:user, student_id: '123456789')
    user.valid?
    expect(user.errors[:student_id]).to include('has already been taken')
  end

  it 'is invalid with non-integer student_id' do
    user = build(:user, student_id: '12345678')
    user.valid?
    expect(user.errors[:student_id]).to include('is too short (minimum is 9 characters)')
  end

  it 'is invalid without utoronto.ca in email' do
    user = build(:user, email: 'JSmith@utoronto.com')
    user.valid?
    expect(user.errors[:email]).to include('is invalid')
  end

  it 'is invalid with password length < 3' do
    user = build(:user, password: 'ab', password_confirmation: 'ab')
    user.valid?
    expect(user.errors[:password]).to include('is too short (minimum is 3 characters)')
  end

  it 'is invalid with wrong password confirmation' do
    user = build(:user, password_confirmation: 'password')
    user.valid?
    expect(user.errors[:password_confirmation]).to include("doesn't match Password")
  end
end
