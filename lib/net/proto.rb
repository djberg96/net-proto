require 'rbconfig'

case RbConfig::CONFIG['host_os']
when /linux/i
  require 'linux/net/proto'
when /sunos|solaris/i
  require 'sunos/net/proto'
else
  require 'generic/net/proto'
end
