require 'rake'
require 'rake/testtask'
require 'rake/clean'

CLEAN.include('**/*.gem', '**/*.rbx', '**/*.rbc')

namespace 'gem' do
  desc 'Create the net-proto gem'
  task :create => :clean do
    spec = eval(IO.read('net-proto.gemspec'))
    if Gem::VERSION.to_f < 2.0
      Gem::Builder.new(spec).build
    else
      require 'rubygems/package'
      Gem::Package.build(spec)
    end
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

Rake::TestTask.new do |t|
  t.warning = true
  t.verbose = true
end

task :default => :test
