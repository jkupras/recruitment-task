# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reservations", type: :request do
  describe "POST /create" do
    let!(:ticket) { create(:ticket, available: 5) }

    context "with valid parameters" do
      let(:params) { { reservation: { tickets_count: "1", ticket_id: ticket.id } } }

      before do
        post "/reservations", params: params
      end

      it "returns a success status" do
        expect(response).to have_http_status(:success)
      end

      it "add new reservation to database" do
        expect(Reservation.count).to eq(1)
      end
    end
    context "with invalid parameters" do
      let(:params) { { reservation: { tickets_count: "1", ticket_id: "invalid" } } }

      before do
        post "/reservations", params: params
      end

      it "returns a not_found status" do
        expect(response).to have_http_status(:not_found)
      end

      it "does not add new reservation to database" do
        expect(Reservation.count).to eq(0)
      end
    end

    context "when not enough tickets" do
      let(:params) { { reservation: { tickets_count: "10", ticket_id: ticket.id } } }

      before do
        post "/reservations", params: params
      end

      it "returns a unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not add new reservation to database" do
        expect(Reservation.count).to eq(0)
      end
    end

    context "when the tickets are booked" do
      let(:params) { { reservation: { tickets_count: "3", ticket_id: ticket.id } } }

      before do
        post "/reservations", params: params
        post "/reservations", params: params
      end

      it "returns a unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "add reservation to database only for avalable tickets" do
        expect(Reservation.count).to eq(1)
      end
    end
  end

  describe "POST /reservations/purchase_ticket" do
    context "with valid parameters" do
      let!(:reservation) { create(:reservation) }
      let(:params) { { reservation_id: "1", token: "XXtokenXX" } }

      before do
        post "/reservations/purchase_ticket", params: params
      end

      it "returns a success status" do
        expect(response).to have_http_status(:success)
      end

      it "change purchased_status" do
        expect(Reservation.first.purchased_status).to eq(true)
      end
    end

    context "when a reservation already paid" do
      let!(:reservation) { create(:reservation) }
      let(:params) { { reservation_id: reservation.id, token: "XXtokenXX" } }

      before do
        post "/reservations/purchase_ticket", params: params
        post "/reservations/purchase_ticket", params: params
      end

      it "returns a unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when 15 minutes had already passed" do
      let!(:reservation) { create(:reservation) }
      let(:params) { { reservation_id: reservation.id, token: "XXtokenXX" } }

      before do
        reservation.created_at = Time.now - 16.minutes
        reservation.save
        post "/reservations/purchase_ticket", params: params
      end

      it "returns a unprocessable_entity status" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "does not change purchased_status" do
        expect(Reservation.first.purchased_status).to eq(false)
      end
    end
  end
end
