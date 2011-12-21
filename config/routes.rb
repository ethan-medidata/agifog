Agifog::Application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :rds do
        resources :servers
      end
    end
  end
end
