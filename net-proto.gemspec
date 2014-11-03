require 'rubygems'

Gem::Specification.new do |gem|
  gem.name       = 'net-proto'
  gem.version    = '1.2.0'
  gem.author     = 'Daniel J. Berger'
  gem.license    = 'Artistic 2.0'
  gem.email      = 'djberg96@gmail.com'
  gem.homepage   = 'https://github.com/djberg96/net-proto'
  gem.summary    = 'A Ruby interface for determining protocol information'
  gem.test_file  = 'test/test_net_proto.rb'
  gem.files      = Dir['**/*'].reject{ |f| f.include?('git') }

  gem.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST', 'doc/netproto.txt']

  gem.add_dependency('ffi', '>= 1.0.0')
  gem.add_development_dependency('test-unit', '>= 2.2.0')
  gem.add_development_dependency('rake')

  gem.description = <<-EOF
    The net-proto library provides an interface for get protocol information
    by name or by number. It can also iterate over the list of protocol
    entries defined on your system.
  EOF
end
