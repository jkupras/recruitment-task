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

  def purchase_ticket
    payment_token = params[:token]
    reservation = Reservation.find(params[:reservation_id].to_i)
    tickets_count = reservation.tickets_count

    return wrong_number_of_tickets unless tickets_count > 0
    if reservation.purchased_status
      render json: { error: "Reservation has been already purchased." }, status: :unprocessable_entity
    elsif reservation.created_at < Time.now - 15.minutes
      render json: { error: "15 minutes have passed since the booking was made. The reservation has been canceled." }, status: :unprocessable_entity
    else
      TicketPayment.call(reservation.ticket, payment_token, tickets_count)
      reservation.purchased_status = true
      reservation.save
      render json: { success: "Payment succeeded." }
    end
  end

  private

  def ticket_avalable?
    @reservation.tickets_count <= @reservation.ticket.available - Reservation.where(ticket: @reservation.ticket).where("created_at > ? AND purchased_status = ?", Time.now - 15.minutes, false).sum(:tickets_count)
  end

  def reservations_params
    params.require(:reservation).permit(:tickets_count, :ticket_id)
  end

  def reserved_ticket_params
    params.permit(:reservation_id, :token)
  end

  def wrong_number_of_tickets
    render json: { error: "Number of tickets must be greater than zero." }, status: :unprocessable_entity
  end
end
