#########################################################################
# example_net_proto.rb
#
# A generic test program for general futzing. You cna run this example
# code via the 'rake example' task.
#########################################################################
require 'net/proto''
include Net

puts "VERSION: " + Proto::VERSION

puts "UDP port: " + Proto.getprotobyname("udp").to_s

unless File::ALT_SEPARATOR
   puts "Name\t\tProto\tAliases"
   puts "=========================="

   Proto.getprotoent.each{ |s|
      if s.name.length > 7
         puts s.name + "\t" + s.proto.to_s + "\t" + s.aliases.join(", ")
      else
         puts s.name + "\t\t" + s.proto.to_s + "\t" + s.aliases.join(", ")
      end
}
end