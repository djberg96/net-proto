require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rbconfig'

CLEAN.include('**/*.gem', '**/*.rbx', '**/*.rbc')

namespace 'gem' do
  desc 'Create the net-proto gem'
  task :create => :clean do
    spec = eval(IO.read('net-proto.gemspec'))
    case RbConfig::CONFIG['host_os']
    when /linux/i
      spec.require_path = 'lib/linux'
      spec.platform = Gem::Platform::CURRENT
    when /sunos|solaris/i
      spec.require_path = 'lib/sunos'
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
  case RbConfig::CONFIG['host_os']
  when /linux/i
    t.libs.unshift 'lib/linux'
  when /sunos|solaris/i
    t.libs.unshift 'lib/sunos'
  end
  t.warning = true
  t.verbose = true
end

task :default => :test
