source 'http://rubygems.org'

gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem 'haml'				# it replaces erb making views much cleaner
gem 'haml-rails', :group => :development
gem 'simple_form'		# Cleanest way to write a form view

gem 'yajl-ruby'
#gem 'fog'
gem 'fog', :git => 'git://github.com/fog/fog.git'

gem 'rack-mauth', :git => "git@github.com:mdsol/rack-mauth.git", :tag => "v0.1.2", :require => 'rack/mauth'
gem 'mauth_signer', :git => 'git@github.com:mdsol/mauth_signer.git', :tag => 'v0.6.3'

group :test do
  gem 'database_cleaner'
  gem 'rails3-generators' #mainly for factory_girl & simple_form at this point
  gem 'rspec-rails'
  gem 'factory_girl_rails'	# mocking
  gem 'cucumber-rails'
  gem "pickle"			# gives you a lot of already defined cucumber steps
  gem 'capybara'
  gem 'guard' 
  gem 'growl'		# guard uses to notify
					#gem 'growl_notify' # if used, guard doesn't show the errors
  gem 'guard-cucumber'
  gem 'rb-fsevent'		# required by guard for notifications
  gem "guard-rspec"		# run rspec when a spec is saved
  gem "launchy" 		# show the web page in case of error
  gem "spork", "> 0.9.0.rc" # Improve loading times during testing
  gem "guard-spork"
  gem 'fakeweb'
  gem "vcr", "=2.0.0.beta1" #using beta2 you get: save_databag_item-databag_doesnt_exist.yml does not appear to be a valid VCR 2.0 cassette
  gem "json_spec" # https://github.com/collectiveidea/json_spec
end
