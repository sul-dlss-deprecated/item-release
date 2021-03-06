# config valid only for Capistrano 3.1
# lock '3.2.1'

set :application, 'item-release'
set :repo_url, 'https://github.com/sul-dlss/item-release.git'

set :home_directory, '/home/lyberadmin'

# set :branch, 'master'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "#{fetch(:home_directory)}/#{fetch(:application)}"
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:stage)}" }

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, []

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :stages, %w[development staging production]
set :default_stage, 'development'
set :linked_dirs, %w[log run config/environments config/certs]
set :linked_files, %w[config/honeybadger.yml]

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 10 do
      within release_path do
        # Uncomment  with the first deploy
        # execute :bundle, :install

        # Comment with the first deploy
        test :bundle, :exec, :controller, :stop
        test :bundle, :exec, :controller, :quit

        # Always call the boot
        execute :bundle, :exec, :controller, :boot
      end
    end
  end

  after :publishing, :restart
end

set :honeybadger_env, fetch(:stage)
