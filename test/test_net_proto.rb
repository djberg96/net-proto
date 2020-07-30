###########################################################################
# test_net_netproto.rb
#
# Test suite for net-proto - all platforms. This test suite should be run
# via the 'rake test' task.
###########################################################################
require 'net/proto'
require 'test-unit'

class TC_Net_Proto < Test::Unit::TestCase

  # These were the protocols listed in my own /etc/protocols file on Solaris 9
  def self.startup
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

  test "version number is set to expected value" do
    assert_equal('1.3.1', Net::Proto::VERSION)
    assert_true(Net::Proto::VERSION.frozen?)
  end

  test "get_protocol method basic functionality" do
    assert_respond_to(Net::Proto, :get_protocol)
  end

  test "get_protocol method accepts a string or a number" do
    assert_nothing_raised{ Net::Proto.get_protocol(1) }
    assert_nothing_raised{ Net::Proto.get_protocol('tcp') }
  end

  test "get_protocol returns nil if protocol not found" do
    assert_nil(Net::Proto.get_protocol(9999999))
  end

  test "get_protocol fails if an invalid type is passed" do
    assert_raise(TypeError){ Net::Proto.get_protocol([]) }
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

  test "getprotobynumber returns nil if not found" do
    assert_equal(nil, Net::Proto.getprotobynumber(9999999))
    assert_equal(nil, Net::Proto.getprotobynumber(-1))
  end

  test "getprotobynumber raises a TypeError if a non-numeric arg is used" do
    assert_raise(TypeError){ Net::Proto.getprotobynumber('foo') }
    assert_raise(TypeError){ Net::Proto.getprotobynumber(nil) }
  end

  test "getprotobyname method basic functionality" do
    assert_respond_to(Net::Proto, :getprotobyname)
    @@protocols.each{ |n| assert_nothing_raised{ Net::Proto.getprotobyname(n) } }
  end

  test "getprotobyname returns the expected result" do
    assert_equal(1, Net::Proto.getprotobyname('icmp'))
    assert_equal(6, Net::Proto.getprotobyname('tcp'))
  end

  test "getprotobyname returns nil if the protocol is not found" do
    assert_nil(Net::Proto.getprotobyname('foo'))
    assert_nil(Net::Proto.getprotobyname('tcpx'))
    assert_nil(Net::Proto.getprotobyname(''))
  end

  test "getprotobyname raises a TypeError if an invalid arg is passed" do
    assert_raises(TypeError){ Net::Proto.getprotobyname(1) }
    assert_raises(TypeError){ Net::Proto.getprotobyname(nil) }
  end

  test "getprotoent basic functionality" do
    assert_respond_to(Net::Proto, :getprotoent)
    assert_nothing_raised{ Net::Proto.getprotoent }
    assert_kind_of(Array, Net::Proto.getprotoent)
  end

  test "getprotoent method returns the expected results" do
    assert_kind_of(Struct::ProtoStruct, Net::Proto.getprotoent.first)
    assert_nil(Net::Proto.getprotoent{})
  end

  test "struct returned by getprotoent method contains the expected data" do
    @protoent = Net::Proto.getprotoent.first
    assert_equal([:name, :aliases, :proto], @protoent.members)
    assert_kind_of(String, @protoent.name)
    assert_kind_of(Array, @protoent.aliases)
    assert_kind_of(Integer, @protoent.proto)
  end

  test "all members of the aliases struct member are strings" do
    @protoent = Net::Proto.getprotoent.first
    assert_true(@protoent.aliases.all?{ |e| e.is_a?(String) })
  end

  test "struct returned by getprotoent method is frozen" do
    @protoent = Net::Proto.getprotoent.first
    assert_true(@protoent.frozen?)
  end

  test "there is no constructor" do
    assert_raise(NoMethodError){ Net::Proto.new }
  end

  test "ffi functions are private" do
    methods = Net::Proto.methods(false).map{ |m| m.to_sym }
    assert_false(methods.include?(:setprotoent))
    assert_false(methods.include?(:endprotoent))
  end

  def teardown
    @protoent = nil
  end

  def self.shutdown
    @@protocols = nil
  end
end
