require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# Default task
task default: [:rubocop, :spec]

# RSpec task
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--format documentation --color'
end

# RuboCop task
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

# Custom tasks
namespace :server do
  desc 'Start the development server'
  task :start do
    exec 'bundle exec rackup -p 9292'
  end
  
  desc 'Start the server in production mode'
  task :production do
    ENV['RACK_ENV'] = 'production'
    exec 'bundle exec rackup -p 9292 -E production'
  end
end

namespace :test do
  desc 'Run tests with coverage'
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['spec'].invoke
  end
  
  desc 'Run integration tests only'
  task :integration do
    sh 'bundle exec rspec spec/integration'
  end
end

desc 'Clean up temporary files'
task :clean do
  sh 'rm -rf coverage/'
  sh 'rm -rf tmp/'
  sh 'rm -f spec/examples.txt'
end

desc 'Show application statistics'
task :stats do
  require 'find'
  
  stats = {
    'Ruby files' => 0,
    'Test files' => 0,
    'Lines of code' => 0,
    'Lines of tests' => 0
  }
  
  Find.find('lib') do |path|
    next unless File.file?(path) && path.end_with?('.rb')
    stats['Ruby files'] += 1
    stats['Lines of code'] += File.readlines(path).size
  end
  
  Find.find('spec') do |path|
    next unless File.file?(path) && path.end_with?('.rb')
    stats['Test files'] += 1
    stats['Lines of tests'] += File.readlines(path).size
  end
  
  puts "\nProject Statistics:"
  stats.each { |key, value| puts "  #{key}: #{value}" }
  
  ratio = stats['Lines of tests'].to_f / stats['Lines of code']
  puts "  Test to code ratio: #{ratio.round(2)}:1"
end
