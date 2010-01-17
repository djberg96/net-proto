require 'rubygems'

# To build a regular gem => rake build_gem
# To build a binary gem  => rake build_binary_gem

Gem::Specification.new do |gem|
   gem.name       = 'net-proto'
   gem.version    = '1.0.5'
   gem.author     = 'Daniel J. Berger'
   gem.license    = 'Artistic 2.0'
   gem.email      = 'djberg96@gmail.com'
   gem.homepage   = 'http://www.rubyforge.org/projects/sysutils'
   gem.platform   = Gem::Platform::RUBY
   gem.summary    = 'A Ruby interface for determining protocol information'
   gem.test_file  = 'test/test_net_proto.rb'
   gem.has_rdoc   = true
   gem.extensions = ['ext/extconf.rb']
   gem.files      = Dir['**/*'].reject{ |f| f.include?('CVS') }

   gem.rubyforge_project = 'sysutils'
   gem.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST', 'doc/netproto.txt']

   gem.add_development_dependency('test-unit', '>= 2.0.3')

   gem.description = <<-EOF
      The net-proto library provides an interface for get protocol information
      by name or by number. It can also iterate over the list of protocol
      entries defined on your system.
   EOF
end