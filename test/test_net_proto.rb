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

class TC_Net_Proto < Test::Unit::TestCase

  # These were the protocols listed in my own /etc/protocols file on Solaris 9
  def self.startup
    @@windows = Config::CONFIG['host_os'] =~ /win32|msdos|mswin|cygwin|mingw/i

    @@protocols = %w/
      ip icmp igmp ggp ipip tcp cbt egp igp pup udp mux hmp
      xns-idp rdp idpr idpr-cmtp sdrp idrp rsvp gre
      mobile ospf pim ipcomp vrrp sctp hopopt ipv6
      ipv6-route ipv6-frag esp ah ipv6-icmp ipv6-nonxt ipv6-opts
    /
  end

  def setup
    @protoent = nil
  end

  test "version number returns expected value" do
    assert_equal('1.0.6', Net::Proto::VERSION)
  end

  test "getprotobynumber basic functionality" do
    assert_respond_to(Net::Proto, :getprotobynumber)
    assert_nothing_raised{ 0.upto(132){ |n| Net::Proto.getprotobynumber(n) } }
    assert_kind_of(String, Net::Proto.getprotobynumber(1))
  end

  test "getprotobynumber returns the expected result" do
    assert_equal('icmp', Net::Proto.getprotobynumber(1))
    assert_equal('tcp', Net::Proto.getprotobynumber(6))
  end

  test "getprotobynumber returns nil if the protocol cannot be found" do
    assert_equal(nil, Net::Proto.getprotobynumber(9999999))
    assert_equal(nil, Net::Proto.getprotobynumber(-1))
  end

  test "getprotobynumber requires a numeric argument" do
    assert_raise(TypeError){ Net::Proto.getprotobynumber('foo') }
    assert_raise(TypeError){ Net::Proto.getprotobynumber(nil) }
  end

  test "getprotobyname basic functionality" do
    assert_respond_to(Net::Proto, :getprotobyname)
    @@protocols.each{ |n| assert_nothing_raised{ Net::Proto.getprotobyname(n) } }
    assert_kind_of(Fixnum, Net::Proto.getprotobyname('tcp'))
  end

  test "getprotobyname returns expected result" do
    assert_equal(1, Net::Proto.getprotobyname('icmp'))
    assert_equal(6, Net::Proto.getprotobyname('tcp'))
  end

  test "getprotobyname returns nil if the protocol cannot be found" do
    assert_equal(nil, Net::Proto.getprotobyname('foo'))
    assert_equal(nil, Net::Proto.getprotobyname('tcpx'))
    assert_equal(nil, Net::Proto.getprotobyname(''))
  end

  test "getprotobyname requires a string argument" do
    assert_raises(TypeError){ Net::Proto.getprotobyname(1) }
    assert_raises(TypeError){ Net::Proto.getprotobyname(nil) }        
  end

  test "getprotoent basic functionality" do
    omit_if(@@windows, 'Skipped on MS Windows')
    assert_respond_to(Net::Proto, :getprotoent)    
    assert_nothing_raised{ Net::Proto.getprotoent }
  end

  test "getprotoent returns an array if no block is provided" do
    omit_if(@@windows, 'Skipped on MS Windows')
    assert_kind_of(Array, Net::Proto.getprotoent)
  end

  test "getprotoent accepts a block" do
    omit_if(@@windows, 'Skipped on MS Windows')
    assert_nothing_raised{ Net::Proto.getprotoent{} }
    assert_nil(Net::Proto.getprotoent{})
  end

  test "getprotoent returns an array of structs" do
    omit_if(@@windows, 'Skipped on MS Windows')
    assert_kind_of(Struct::ProtoStruct, Net::Proto.getprotoent.first)
  end

  test "structs returned by getprotoent contain specific members" do
    omit_if(@@windows, 'Skipped on MS Windows')
    @protoent = Net::Proto.getprotoent.first
    assert_equal(['name', 'aliases', 'proto'], @protoent.members)
  end

  test "struct members are of a specific type" do
    omit_if(@@windows, 'Skipped on MS Windows')
    @protoent = Net::Proto.getprotoent.first
    assert_kind_of(String, @protoent.name)
    assert_kind_of(Array, @protoent.aliases)
    assert_kind_of(Integer, @protoent.proto)
  end

  test "aliases struct member returns an array of strings" do
    omit_if(@@windows, 'Skipped on MS Windows')
    @protoent = Net::Proto.getprotoent.first
    assert_true(@protoent.aliases.all?{ |e| e.is_a?(String) })
  end

  test "the structs returned by getprotoent are frozen" do
    omit_if(@@windows, 'Skipped on MS Windows')
    @protoent = Net::Proto.getprotoent.first
    assert_true(@protoent.frozen?)
  end
   
  test "there is no constructor for the Proto class" do
    assert_raise(NoMethodError){ Net::Proto.new }      
  end

  def teardown
    @protoent = nil
  end
   
  def self.shutdown
    @@protocols = nil
  end
end
