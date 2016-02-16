require 'rake'
require 'rake/testtask'
require 'robot-controller/tasks'
require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |task|
 task.options = ['-l'] # run lint cops only
end

# Import external rake tasks
Dir.glob('lib/tasks/*.rake').each { |r| import r }

task default: :ci

desc "run continuous integration suite (tests, coverage, rubocop lint)"
task :ci => [:spec, :rubocop]

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

desc 'Get application version'
task :app_version do
  puts File.read(File.expand_path('../VERSION',__FILE__)).chomp
end

desc 'Load complete environment into rake process'
task :environment do
  require_relative 'config/boot'
end
