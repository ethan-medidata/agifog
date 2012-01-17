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
      
      namespace :elb do
        resources :load_balancers
      end
      
      namespace :compute do
        resources :servers do
          member do
            put 'reboot'
            put 'start'
            put 'stop'
          end
        end
        resources :security_groups do
          member do
            put 'authorize'
            put 'revoke'
          end
        end
      end
      
      
    end #v1
  end #api
end
