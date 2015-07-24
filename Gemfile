source 'https://rubygems.org'

gem 'addressable', '~> 2.3.5'      # pin to avoid RDF bug
gem 'dor-services', '>= 4.20.3', '< 5.0'
gem 'lyber-core', '~> 3.2', '>=3.2.4'
gem 'robot-controller', '~> 2.0' # requires Resque
gem 'pry', '~> 0.10.0'          # for bin/console
gem 'slop', '>= 3.5.0'          # for bin/run_robot
gem 'rake', '>= 10.3.2'
gem 'dor-fetcher'
gem 'retries'
gem 'dor-workflow-service'
gem 'rspec'

group :development,:test do
  gem 'coveralls', require: false 
  gem 'vcr'  
end

group :development do
  if File.exists?(mygems = File.join(ENV['HOME'],'.gemfile'))
    instance_eval(File.read(mygems))
  end
  gem 'awesome_print'
  gem 'debugger', :platform => :ruby_19
	gem 'yard'
	gem 'capistrano', '>= 3.2.1'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler', '~> 1.1'
  gem 'lyberteam-capistrano-devel', "~> 3.0"
  gem 'json_pure'
end
