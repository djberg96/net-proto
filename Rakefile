require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

desc 'Clean the build files for the net-proto source' 
task :clean do
  Dir['*.gem'].each{ |f| File.delete(f) }
  Dir['**/*.rbc'].each{ |f| File.delete(f) }

  make = RUBY_PLATFORM.match('mswin') ? 'nmake' : 'make'

  Dir.chdir('ext') do
    proto_file = 'proto.' + Config::CONFIG['DLEXT']
    if File.exists?('proto.o') || File.exists?(proto_file)
      sh "#{make} distclean"
    end
    rm_rf('proto.c') if File.exists?('proto.c')
    rm_rf('net') if File.exists?('net')
  end

  rm_rf('net') if File.exists?('net')
  rm_rf('lib') if File.exists?('lib')
end

desc 'Build the net-proto library'
task :build => [:clean] do
  make = RUBY_PLATFORM.match('mswin') ? 'nmake' : 'make'
  Dir.chdir('ext') do
    ruby 'extconf.rb'
    sh make
    build_file = 'proto.' + Config::CONFIG['DLEXT']
    Dir.mkdir('net') unless File.exists?('net')
    FileUtils.cp(build_file, 'net')
  end
end

namespace :gem do
  desc 'Build a standard gem'
  task :create => :clean do
    rm_rf('lib') if File.exists?('lib')
    spec = eval(IO.read('net-proto.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc 'Build a binary gem'
  task :create_binary => [:build] do
    file = 'ext/net/proto.' + CONFIG['DLEXT']
    mkdir_p('lib/net')
    mv(file, 'lib/net')

    spec = eval(IO.read('net-proto.gemspec'))
    spec.extensions = nil
    spec.files = spec.files.reject{ |f| f.include?('ext/') }
    spec.platform = Gem::Platform::CURRENT

    Gem::Builder.new(spec).build
  end

  desc 'Install the net-proto library (gem)'
  task :install => [:create] do
    ruby 'net-proto.gemspec'
    file = Dir["net-proto*.gem"].last
    sh "gem install #{file}"
  end
end

desc 'Run the example net-proto program'
task :example => [:build] do
  Dir.mkdir('net') unless File.exists?('net')
  ruby '-Iext examples/example_net_proto.rb'
end

Rake::TestTask.new do |t|
  task :test => :build
  t.libs << 'ext'
  t.warning = true
  t.verbose = true
end

task :default => :test
