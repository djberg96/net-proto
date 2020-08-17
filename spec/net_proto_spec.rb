###########################################################################
# net_netproto_spec.rb
#
# Test suite for net-proto  all platforms. This test suite should be run
# via the 'rake spec' task.
###########################################################################
require 'net/proto'
require 'rspec'

RSpec.describe Net::Proto do
  # These were the protocols listed in my own /etc/protocols file on Solaris 9
  let(:protocols) do
    %w[
      ip icmp igmp ggp ipip tcp cbt egp igp pup udp mux hmp
      xns-idp rdp idpr idpr-cmtp sdrp idrp rsvp gre
      mobile ospf pim ipcomp vrrp sctp hopopt ipv6
      ipv6-route ipv6-frag esp ah ipv6-icmp ipv6-nonxt ipv6-opts
    ]
  end

  example "version number is set to expected value" do
    expect(Net::Proto::VERSION).to eq('1.4.0')
    expect(Net::Proto::VERSION.frozen?).to eq(true)
  end

  example "get_protocol method basic functionality" do
    expect(Net::Proto).to respond_to(:get_protocol)
  end

  example "get_protocol method accepts a string or a number" do
    expect{ Net::Proto.get_protocol(1) }.not_to raise_error
    expect{ Net::Proto.get_protocol('tcp') }.not_to raise_error
  end

  example "get_protocol returns nil if protocol not found" do
    expect(Net::Proto.get_protocol(9999999)).to be_nil
  end

  example "get_protocol fails if an invalid type is passed" do
    expect{ Net::Proto.get_protocol([]) }.to raise_error(TypeError)
  end

  example "getprotobynumber basic functionality" do
    expect(Net::Proto).to respond_to(:getprotobynumber)
    expect{ 0.upto(132){ |n| Net::Proto.getprotobynumber(n) } }.not_to raise_error
    expect(Net::Proto.getprotobynumber(1)).to be_kind_of(String)
  end

  example "getprotobynumber returns the expected result" do
    expect(Net::Proto.getprotobynumber(1)).to eq('icmp')
    expect(Net::Proto.getprotobynumber(6)).to eq('tcp')
  end

  example "getprotobynumber returns nil if not found" do
    expect(Net::Proto.getprotobynumber(9999999)).to eq(nil)
    expect(Net::Proto.getprotobynumber(-1)).to eq(nil)
  end

  example "getprotobynumber raises a TypeError if a non-numeric arg is used" do
    expect{ Net::Proto.getprotobynumber('foo') }.to raise_error(TypeError)
    expect{ Net::Proto.getprotobynumber(nil) }.to raise_error(TypeError)
  end

  example "getprotobyname method basic functionality" do
    expect(Net::Proto).to respond_to(:getprotobyname)
    protocols.each{ |n| expect{ Net::Proto.getprotobyname(n) }.not_to raise_error }
  end

  example "getprotobyname returns the expected result" do
    expect(Net::Proto.getprotobyname('icmp')).to eq(1)
    expect(Net::Proto.getprotobyname('tcp')).to eq(6)
  end

  example "getprotobyname returns nil if the protocol is not found" do
    expect(Net::Proto.getprotobyname('foo')).to be_nil
    expect(Net::Proto.getprotobyname('tcpx')).to be_nil
    expect(Net::Proto.getprotobyname('')).to be_nil
  end

  example "getprotobyname raises a TypeError if an invalid arg is passed" do
    expect{ Net::Proto.getprotobyname(1) }.to raise_error(TypeError)
    expect{ Net::Proto.getprotobyname(nil) }.to raise_error(TypeError)
  end

  example "getprotoent basic functionality" do
    expect(Net::Proto).to respond_to(:getprotoent)
    expect{ Net::Proto.getprotoent }.not_to raise_error
    expect(Net::Proto.getprotoent).to be_kind_of(Array)
  end

  example "getprotoent method returns the expected results" do
    expect(Net::Proto.getprotoent.first).to be_kind_of(Struct::ProtoStruct)
    expect(Net::Proto.getprotoent{}).to be_nil
  end

  example "struct returned by getprotoent method contains the expected data" do
    protoent = Net::Proto.getprotoent.first
    expect( protoent.members).to eq([:name, :aliases, :proto])
    expect( protoent.name).to be_kind_of(String)
    expect( protoent.aliases).to be_kind_of(Array)
    expect( protoent.proto).to be_kind_of(Integer)
  end

  example "all members of the aliases struct member are strings" do
    protoent = Net::Proto.getprotoent.first
    expect(protoent.aliases.all?{ |e| e.is_a?(String) }).to eq(true)
  end

  example "struct returned by getprotoent method is frozen" do
    protoent = Net::Proto.getprotoent.first
    expect(protoent.frozen?).to eq(true)
  end

  example "there is no constructor" do
    expect{ Net::Proto.new }.to raise_error(NoMethodError)
  end

  example "ffi functions are private" do
    methods = Net::Proto.methods(false)
    expect(methods.include?(:setprotoent)).to eq(false)
    expect(methods.include?(:endprotoent)).to eq(false)
  end
end
