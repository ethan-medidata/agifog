Agifog::Application.routes.draw do
  match "/app_status" => "application#app_status"
  namespace :api do
    namespace :v1 do
      namespace :auto_scaling do
        resources :configurations, :only => [:index, :show, :create, :destroy]
      end
      
      namespace :rds do
        resources :servers, :only => [:index, :show, :create, :destroy, :update]
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
      namespace :dynect do
        constraints(:id => /[^\/]+/ ) do #accepts dots in the params
          resources :zones, :only => [:index, :show] do
            resources :nodes, :only => [:index, :show, :create, :destroy]
          end
        end
      end
      
      namespace :iam do
        resources :users, :only => [:index, :show, :create, :destroy] do
          resources :policies, :only => [:index, :show, :create, :destroy]
          resources :access_keys, :only => [:index, :show, :create, :destroy]
        end
      end
      
      
    end #v1
  end #api
end
