require "faker"

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password do
      Faker::Internet.password(min_length: 8, max_length: 16, mix_case: true, special_characters: true).to_s
    end
  end
end
