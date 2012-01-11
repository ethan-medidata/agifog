Agifog::Application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :rds do
        resources :servers
        resources :security_groups do
          member do
            put 'authorize'
            put 'revoke'
          end
        end
      end
      namespace :compute do
        resources :servers
      end
    end
  end
end
