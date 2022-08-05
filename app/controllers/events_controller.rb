# frozen_string_literal: true

class EventsController < ApiController
  before_action :set_event, only: :show

  def index
    @events = Event.all
  end

  def show
    render :show
  end

  def available
    @events = Event.joins(:ticket).where("time > ? AND available > ?", Time.now, 0)
  end

  def tickets
    @tickets = Event.find(params[:id]).reservations.where("reservations.created_at > ? OR purchased_status = ?", Time.now - 15.minutes, true)
  end

  private

  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound => error
    not_found_error(error)
  end
end
