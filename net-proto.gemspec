require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'net-proto'
  spec.version    = '1.4.0'
  spec.author     = 'Daniel J. Berger'
  spec.license    = 'Apache-2.0'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'https://github.com/djberg96/net-proto'
  spec.summary    = 'A Ruby interface for determining protocol information'
  spec.test_file  = 'test/test_net_proto.rb'
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = Dir['certs/*']

  spec.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST', 'doc/netproto.txt']

  spec.add_dependency('ffi', '~> 1.0')
  spec.add_development_dependency('rspec', '~> 3.9')
  spec.add_development_dependency('rake')

  spec.metadata = {
    'homepage_uri'      => 'https://github.com/djberg96/net-proto',
    'bug_tracker_uri'   => 'https://github.com/djberg96/net-proto/issues',
    'changelog_uri'     => 'https://github.com/djberg96/net-proto/blob/ffi/CHANGES',
    'documentation_uri' => 'https://github.com/djberg96/net-proto/wiki',
    'source_code_uri'   => 'https://github.com/djberg96/net-proto',
    'wiki_uri'          => 'https://github.com/djberg96/net-proto/wiki'
  }

  spec.description = <<-EOF
    The net-proto library provides an interface for get protocol information
    by name or by number. It can also iterate over the list of protocol
    entries defined on your system.
  EOF
end
