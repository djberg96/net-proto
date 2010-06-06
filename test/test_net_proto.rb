###########################################################################
# test_net_netproto.rb
#
# Test suite for net-proto - all platforms. This test suite should be run
# via the 'rake test' task.
###########################################################################
require 'rubygems'
gem 'test-unit'

require 'net/proto'
require 'test/unit'
require 'rbconfig'

class TC_Net_Proto < Test::Unit::TestCase

   # These were the protocols listed in my own /etc/protocols file on Solaris 9
   def self.startup
      @@protocols = %w/
         ip icmp igmp ggp ipip tcp cbt egp igp pup udp mux hmp
         xns-idp rdp idpr idpr-cmtp sdrp idrp rsvp gre
         mobile ospf pim ipcomp vrrp sctp hopopt ipv6
         ipv6-route ipv6-frag esp ah ipv6-icmp ipv6-nonxt ipv6-opts
      /

      @@windows = Config::CONFIG['host_os'] =~ /msdos|mswin|win32|cygwin|mingw/i
   end

   def setup
      @protoent = nil
   end

   def test_version
      assert_equal('1.1.0', Net::Proto::VERSION)
   end

   def test_getprotobynumber_basic
      assert_respond_to(Net::Proto, :getprotobynumber)
      assert_nothing_raised{ 0.upto(132){ |n| Net::Proto.getprotobynumber(n) } }
      assert_kind_of(String, Net::Proto.getprotobynumber(1))
   end

   def test_getprotobynumber_result_expected
      assert_equal('icmp', Net::Proto.getprotobynumber(1))
      assert_equal('tcp', Net::Proto.getprotobynumber(6))
   end

   def test_getprotbynumber_result_not_expected
      assert_equal(nil, Net::Proto.getprotobynumber(9999999))
      assert_equal(nil, Net::Proto.getprotobynumber(-1))
   end

   def test_getprotobynumber_expected_errors
      assert_raise(TypeError){ Net::Proto.getprotobynumber('foo') }
      assert_raise(TypeError){ Net::Proto.getprotobynumber(nil) }
      assert_raise(RangeError){ Net::Proto.getprotobynumber(999999999999) }
   end

   def test_getprotobyname_basic
      assert_respond_to(Net::Proto, :getprotobyname)
      @@protocols.each{ |n| assert_nothing_raised{ Net::Proto.getprotobyname(n) } }
   end

   def test_getprotobyname_result_expected
      assert_equal(1, Net::Proto.getprotobyname('icmp'))
      assert_equal(6, Net::Proto.getprotobyname('tcp'))
   end

   def test_getprotobyname_result_not_expected
      assert_equal(nil, Net::Proto.getprotobyname('foo'))
      assert_equal(nil, Net::Proto.getprotobyname('tcpx'))
      assert_equal(nil, Net::Proto.getprotobyname(''))
   end

   def test_getprotobyname_expected_errors
      assert_raises(TypeError){ Net::Proto.getprotobyname(1) }
      assert_raises(TypeError){ Net::Proto.getprotobyname(nil) }        
   end

   def test_getprotoent_basic
      omit_if(@@windows, 'Skipped on MS Windows')

      assert_respond_to(Net::Proto, :getprotoent)    
      assert_nothing_raised{ Net::Proto.getprotoent }
      assert_kind_of(Array, Net::Proto.getprotoent)
   end

   def test_getprotoent
      omit_if(@@windows, 'Skipped on MS Windows')

      assert_kind_of(Struct::ProtoStruct, Net::Proto.getprotoent.first)
      assert_nil(Net::Proto.getprotoent{})
   end

   def test_getprotoent_struct
      omit_if(@@windows, 'Skipped on MS Windows')

      @protoent = Net::Proto.getprotoent.first
      assert_equal(['name', 'aliases', 'proto'], @protoent.members)
      assert_kind_of(String, @protoent.name)
      assert_kind_of(Array, @protoent.aliases)
      assert_kind_of(Integer, @protoent.proto)
   end

   def test_getprotoent_struct_aliases_member
      omit_if(@@windows, 'Skipped on MS Windows')

      @protoent = Net::Proto.getprotoent.first
      assert_true(@protoent.aliases.all?{ |e| e.is_a?(String) })
   end

   def test_getprotoent_struct_frozen
      omit_if(@@windows, 'Skipped on MS Windows')

      @protoent = Net::Proto.getprotoent.first
      assert_true(@protoent.frozen?)
   end
   
   def test_constructor_illegal
      assert_raise(NoMethodError){ Net::Proto.new }      
   end

   def teardown
      @protoent = nil
   end
   
   def self.shutdown
      @@protocols = nil
   end
end
