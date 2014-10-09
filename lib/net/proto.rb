require 'rbconfig'

case RbConfig::CONFIG['host_os']
  when /linux/i
    require 'linux/net/proto'
  when /sunos|solaris/i
    require 'sunos/net/proto'
  when /mingw|cygwin|win32|windows|mswin/i
    require 'windows/net/proto'
  else
    require 'generic/net/proto'
end
