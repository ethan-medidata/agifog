Agifog::Application.routes.draw do
  match "/app_status" => "application#app_status"
  namespace :api do
    namespace :v1 do
      namespace :rds do
        resources :servers, :only => [:index, :show, :create, :destroy]
        resources :security_groups, :only => [:index, :show, :create, :destroy] do
          member do
            put 'authorize'
            put 'revoke'
          end
        end
      end
      
      namespace :elb do
        resources :load_balancers, :only => [:index, :show, :create, :destroy] do
          resources :instances, :only => [:index, :show, :create, :destroy]
          resource :health_check, :only => [:show, :create, :destroy]
        end
      end
      
      namespace :compute do
        resources :servers, :only => [:index, :show, :create, :destroy] do
          member do
            put 'reboot'
            put 'start'
            put 'stop'
          end
        end
        resources :security_groups, :only => [:index, :show, :create, :destroy] do
          member do
            put 'authorize'
            put 'revoke'
          end
        end
      end
      
      
    end #v1
  end #api
end
