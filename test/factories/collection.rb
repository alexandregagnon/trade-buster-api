require "faker"

FactoryBot.define do
  factory :collection do
    user
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
  end
end
