# frozen_string_literal: true

class Reservation < ApplicationRecord
  belongs_to :ticket
  has_one :event, through: :ticket
  validates :tickets_count, presence: true
end
