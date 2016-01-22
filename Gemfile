source 'https://rubygems.org'

gem 'dor-services', '~> 5.3'
gem 'lyber-core', '~> 3.3'
gem 'robot-controller', '~> 2.0' # requires Resque
gem 'pry', '~> 0.10.0'          # for bin/console
gem 'slop', '>= 3.5.0'          # for bin/run_robot
gem 'rake', '>= 10.3.2'
gem 'dor-fetcher'
gem 'retries'
gem 'dor-workflow-service'
gem 'rspec'

group :development, :test do
  gem 'coveralls', require: false
  gem 'vcr'
end

group :development do
  if File.exists?(mygems = File.join(ENV['HOME'],'.gemfile'))
    instance_eval(File.read(mygems))
  end
  gem 'awesome_print'
  gem 'yard'
  gem 'dlss-capistrano'
  gem 'json_pure'
end
