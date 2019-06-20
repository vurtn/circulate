Rails.application.routes.draw do
  devise_for :users

  namespace :signup do
    resources :members, only: [:new, :create]
    resources :agreements, only: [:show] do
      resource :acceptance, only: [:create, :destroy]
    end
    get "confirmation", to: "confirmations#show"
  end

  scope :admin do
    resources :agreements
    resources :borrow_policies
    resources :categories
    resources :items do
      get :number
    end
    resources :loans
    resources :members

    post "search", to: "searches#create"
    get "search", to: "searches#show"
  end

  get "/ui/names", to: "ui#names"
  get "/ui/brands", to: "ui#brands"

  if Rails.env.development?
    post "/dev/time", to: "dev#set_time"
    delete "/dev/time", to: "dev#clear_time"
  end

  root to: "home#index"
end