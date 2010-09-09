require 'rake'
require 'rake/testtask'
require 'rbconfig'
include Config

namespace 'gem' do
  desc 'Remove any old gem files'
  task :clean do
    Dir['*.gem'].each{ |f| File.delete(f) }
  end

  desc 'Create the net-proto gem'
  task :create => :clean do
    spec = eval(IO.read('net-proto.gemspec'))
    if Config::CONFIG['host_os'] =~ /linux/i
      spec.require_path = 'lib/linux'
      spec.platform = Gem::Platform::CURRENT
    end
    Gem::Builder.new(spec).build
  end

  desc 'Install the net-proto gem'
  task :install => [:create] do
    file = Dir["net-proto*.gem"].last
    sh "gem install #{file}"
  end
end

desc 'Run the example net-proto program'
task :example do
  ruby '-Ilib examples/example_net_proto.rb'
end

Rake::TestTask.new do |t|
  t.libs.unshift 'lib/linux' if Config::CONFIG['host_os'] =~ /linux/i
  t.warning = true
  t.verbose = true
end

task :default => :test
