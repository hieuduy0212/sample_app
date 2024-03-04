Rails.application.routes.draw do
  get 'relationship/create'
  get 'relationship/destroy'

  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    root "static_pages#home"

    get "static_pages/home"
    get "static_pages/help"

    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    resources :users, except: %i(new create)

    get "/login", to: "sessions#new" # get log in page
    post "/login", to: "sessions#create" # do log in
    delete "/logout", to: "sessions#destroy"

    resources :users do
      member do
        get :following, :followers
      end
    end

    resources :account_activations, only: :edit
    resources :password_resets, except: %i(index destroy show)
    resources :microposts, only: %i(create destroy)
    resources :relationships, only: %i(create destroy)
  end
end
