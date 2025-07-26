require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

CLEAN.include('**/*.gem', '**/*.rbx', '**/*.rbc', '**/*.lock')

namespace 'gem' do
  desc 'Create the net-proto gem'
  task :create => :clean do
    require 'rubygems/package'
    spec = Gem::Specification.load('net-proto.gemspec')
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec)
  end

  desc 'Install the net-proto gem'
  task :install => [:create] do
    file = Dir["net-proto*.gem"].last
    sh "gem install -l #{file}"
  end
end

desc 'Run the example net-proto program'
task :example do
  ruby '-Ilib examples/example_net_proto.rb'
end

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
  t.rspec_opts = '-f documentation'
  t.pattern = ['spec/net_proto_spec.rb']
end

# Clean up afterwards
Rake::Task[:spec].enhance do
  Rake::Task[:clean].invoke
end

task :default => :spec
