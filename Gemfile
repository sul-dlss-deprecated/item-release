source 'https://rubygems.org'

gem 'dor-services', '~> 5.4', '>= 5.4.2'
gem 'lyber-core', '~> 4.0'
gem 'robot-controller', '~> 2.0' # requires Resque
gem 'pry', '~> 0.10.0'          # for bin/console
gem 'slop', '>= 3.5.0'          # for bin/run_robot
gem 'rake', '>= 10.3.2'
gem 'dor-fetcher'
gem 'retries'
gem 'dor-workflow-service', '~> 2.0'

group :development, :test do
  gem 'coveralls', require: false
  gem 'vcr'
  gem 'rspec'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :development do
  if File.exist?(mygems = File.join(ENV['HOME'],'.gemfile'))
    instance_eval(File.read(mygems))
  end
  gem 'yard'
  gem 'dlss-capistrano'
end
