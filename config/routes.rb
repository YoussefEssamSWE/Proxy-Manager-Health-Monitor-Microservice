Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :proxies
      
      # Custom routes
      get 'proxy/best', to: 'proxies#best'
      post 'proxy/check-all', to: 'proxies#check_all'
    end
  end

  # Health check endpoint
  get '/health', to: proc { [200, {}, ['OK']] }
end
