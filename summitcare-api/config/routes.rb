Rails.application.routes.draw do
  # Staff console (Solution 1): cookie sessions, MFA enrollment.
  resource :session, only: %i[new create destroy]
  namespace :console do
    root "dashboard#show"
    resource :mfa_enrollment, only: %i[new create]
  end

  namespace :api do
    namespace :v1 do
      resource :session, only: %i[create destroy]                 # password sign-in (Solution 3)
      resource :passkey_session, only: %i[new create]             # Solution 1
      resource :passkey_registration, only: %i[new create]        # Solution 1
      resource :token_refresh, only: :create                      # Solution 3
      resources :device_sessions, only: %i[index destroy]         # Solution 30
      resources :break_glass_grants, only: :create                # Solution 6
      resources :notification_previews, only: :show               # Solution 24
      resources :analytics_events, only: :create                  # Solution 26

      resources :patients, only: %i[index show] do
        resources :lab_results, only: %i[index show update]
        resources :appointments, only: %i[index show create]
        resources :messages, only: %i[index create]
        resources :documents, only: %i[index show create]         # Solution 9
        resource :record_export, only: %i[create show]            # Solution 18
        resources :amendment_requests, only: %i[index create]     # Solution 20
      end

      namespace :partners do
        resources :lab_results, only: :create                     # Solution 27
      end
    end
  end

  # Load balancer health check; excluded from the HTTPS redirect (Solution 10).
  get "up" => "rails/health#show", as: :rails_health_check
end
