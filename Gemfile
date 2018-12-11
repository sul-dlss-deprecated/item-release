source 'https://rubygems.org'

gem 'dor-services', '~> 6.0'
gem 'lyber-core', '~> 4.0', '>= 4.0.3'
gem 'robot-controller', '~> 2.0' # requires Resque
gem 'pry', '~> 0.10.0'          # for bin/console
gem 'slop', '>= 3.5.0'          # for bin/run_robot
gem 'rake', '>= 10.3.2'
gem 'dor-fetcher'
gem 'retries'
gem 'bluepill'

group :development, :test do
  gem 'coveralls', require: false
  gem 'vcr'
  gem 'rspec'
  gem 'rubocop', '~> 0.52.1'
  gem 'rubocop-rspec'
  gem 'webmock'
end

group :development do
  if File.exist?(mygems = File.join(ENV['HOME'],'.gemfile'))
    instance_eval(File.read(mygems))
  end
  gem 'capistrano', '~> 3.0'
  gem 'capistrano-bundler', '~> 1.1'
  gem 'dlss-capistrano'
end

gem 'honeybadger'
