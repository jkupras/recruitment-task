# frozen_string_literal: true

json.event_ticket do
  json.array! @tickets, :id, :purchased_status, :tickets_count
end
