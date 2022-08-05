# frozen_string_literal: true

FactoryBot.define do
  factory :reservation do
    tickets_count { 1 }
    ticket
    purchased_status { false }
  end
end
