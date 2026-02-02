Rails.application.routes.draw do
  # User authentication (passwordless)
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"

  # Content browsing
  resources :topics, only: [ :index, :show ] do
    collection do
      get :by_year
      get :new_uploads
      get :top_topics
      get :favorites
    end
    member do
      post :toggle_favorite
    end
  end

  # Local files (user-facing, read-only)
  resources :local_files, only: [ :index, :show ]

  # Search
  get "search", to: "search#index", as: :search
  get "search/autocomplete", to: "search#autocomplete", as: :search_autocomplete
  get "search/results", to: "search#results", as: :search_results

  # Media players
  resources :topic_files, only: [] do
    member do
      get :audio, to: "audio_player#show"
      get :pdf, to: "pdf_viewer#show"
    end
  end

  # Error pages
  get "errors/not_found", to: "errors#not_found", as: :not_found
  get "errors/audio_not_found", to: "errors#audio_not_found", as: :audio_not_found
  get "errors/pdf_not_found", to: "errors#pdf_not_found", as: :pdf_not_found
  get "errors/unsupported_browser", to: "errors#unsupported_browser", as: :unsupported_browser

  # Admin authentication and management
  namespace :admin do
    get "login", to: "sessions#new", as: :login
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy", as: :logout

    resources :local_files, only: [ :index, :new, :create, :show, :destroy ] do
      collection do
        delete :destroy_folder
      end
    end

    # Activity logs
    get "activity_log", to: "dashboard#activity_log", as: :activity_log
    get "admin_log", to: "dashboard#admin_log", as: :admin_log

    root to: "dashboard#index"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "topics#index"
end
