Agifog::Application.routes.draw do
  match "/app_status" => "application#app_status"
  namespace :api do
    namespace :v1 do
      namespace :auto_scaling do
        resources :configurations, :only => [:index, :show, :create, :destroy]
      end
      
      namespace :rds do
        resources :servers, :only => [:index, :show, :create, :destroy]
        resources :parameter_groups, :only => [:index, :show]
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
          get 'search', :on => :collection # security_groups/search?contains=foo
          member do
            put 'authorize'
            put 'revoke'
          end
        end
      end
      
      
    end #v1
  end #api
end
