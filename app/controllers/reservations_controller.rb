# frozen_string_literal: true

class ReservationsController < ApplicationController
  def create
    @reservation = Reservation.new(reservations_params)
    if ticket_avalable? && @reservation.save
      render json: { success: "Reservation created succeeded." }
    else
      render json: { error: "Reservation can not be created." }, status: :unprocessable_entity
    end
  end

  private

  def ticket_avalable?
    @reservation.tickets_count <= @reservation.ticket.available - Reservation.where(ticket: @reservation.ticket).where("created_at > ? AND purchased_status = ?", Time.now - 15.minutes, false).sum(:tickets_count)
  end

  def reservations_params
    params.require(:reservation).permit(:tickets_count, :ticket_id)
  end
end
