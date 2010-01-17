require 'mkmf'
require 'fileutils'
require 'rbconfig'

Dir.mkdir('net') unless File.exists?('net')

case Config::CONFIG['host_os']
   when /sunos|solaris/i
      have_library('socket')
      FileUtils.cp('sunos/sunos.c', 'net/proto.c')
   when /linux/i
      FileUtils.cp('linux/linux.c', 'net/proto.c')
   when /win32|windows|dos|mingw|cygwin/i
      FileUtils.cp('windows/windows.c', 'net/proto.c')
   else
      FileUtils.cp('generic/generic.c', 'net/proto.c')
end

create_makefile('net/proto', 'net')
