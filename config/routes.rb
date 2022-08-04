# frozen_string_literal: true

Rails.application.routes.draw do
  scope defaults: { format: 'json' } do
    resources :events, only: %i(index show) do
      collection do
        get :available
        get '/:id/tickets' => 'events#tickets'
      end
    end

    resources :tickets, only: %i(index) do
      collection do
        post :buy
      end
    end
    resources :reservations, only: %i(index, create) do
      collection do
        post :purchase_ticket
      end
    end
  end
end
