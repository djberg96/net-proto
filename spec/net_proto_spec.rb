# frozen_string_literal: true

###########################################################################
# net_proto_spec.rb
#
# Test suite for net-proto on all platforms. This test suite should be run
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

  example 'version number is set to expected value' do
    expect(Net::Proto::VERSION).to eq('1.4.2')
    expect(Net::Proto::VERSION).to be_frozen
  end

  example 'get_protocol method basic functionality' do
    expect(described_class).to respond_to(:get_protocol)
  end

  example 'get_protocol method accepts a string or a number' do
    expect{ described_class.get_protocol(1) }.not_to raise_error
    expect{ described_class.get_protocol('tcp') }.not_to raise_error
  end

  example 'get_protocol returns nil if protocol not found' do
    expect(described_class.get_protocol(9999999)).to be_nil
  end

  example 'get_protocol fails if an invalid type is passed' do
    expect{ described_class.get_protocol([]) }.to raise_error(TypeError)
  end

  example 'getprotobynumber basic functionality' do
    expect(described_class).to respond_to(:getprotobynumber)
    expect{ 0.upto(132){ |n| described_class.getprotobynumber(n) } }.not_to raise_error
    expect(described_class.getprotobynumber(1)).to be_kind_of(String)
  end

  example 'getprotobynumber returns the expected result' do
    expect(described_class.getprotobynumber(1)).to eq('icmp')
    expect(described_class.getprotobynumber(6)).to eq('tcp')
  end

  example 'getprotobynumber returns nil if not found' do
    expect(described_class.getprotobynumber(9999999)).to be(nil)
    expect(described_class.getprotobynumber(-1)).to be(nil)
  end

  example 'getprotobynumber raises a TypeError if a non-numeric arg is used' do
    expect{ described_class.getprotobynumber('foo') }.to raise_error(TypeError)
    expect{ described_class.getprotobynumber(nil) }.to raise_error(TypeError)
  end

  example 'getprotobyname method basic functionality' do
    expect(described_class).to respond_to(:getprotobyname)
    protocols.each{ |n| expect{ described_class.getprotobyname(n) }.not_to raise_error }
  end

  example 'getprotobyname returns the expected result' do
    expect(described_class.getprotobyname('icmp')).to eq(1)
    expect(described_class.getprotobyname('tcp')).to eq(6)
  end

  example 'getprotobyname returns nil if the protocol is not found' do
    expect(described_class.getprotobyname('foo')).to be_nil
    expect(described_class.getprotobyname('tcpx')).to be_nil
    expect(described_class.getprotobyname('')).to be_nil
  end

  example 'getprotobyname raises a TypeError if an invalid arg is passed' do
    expect{ described_class.getprotobyname(1) }.to raise_error(TypeError)
    expect{ described_class.getprotobyname(nil) }.to raise_error(TypeError)
  end

  example 'getprotoent basic functionality' do
    expect(described_class).to respond_to(:getprotoent)
    expect{ described_class.getprotoent }.not_to raise_error
    expect(described_class.getprotoent).to be_kind_of(Array)
  end

  example 'getprotoent method returns the expected results' do
    expect(described_class.getprotoent.first).to be_kind_of(Struct::ProtoStruct)
    expect(described_class.getprotoent{}).to be_nil # nil if block provided
  end

  example 'struct returned by getprotoent method contains the expected data' do
    protoent = described_class.getprotoent.first
    expect(protoent.members).to eq(%i[name aliases proto])
    expect(protoent.name).to be_kind_of(String)
    expect(protoent.aliases).to be_kind_of(Array)
    expect(protoent.proto).to be_kind_of(Integer)
  end

  example 'all members of the aliases struct member are strings' do
    protoent = described_class.getprotoent.first
    expect(protoent.aliases.all?{ |e| e.is_a?(String) }).to be(true)
  end

  example 'struct returned by getprotoent method is frozen' do
    protoent = described_class.getprotoent.first
    expect(protoent.frozen?).to be(true)
  end

  example 'there is no constructor' do
    expect{ described_class.new }.to raise_error(NoMethodError)
  end

  example 'ffi functions are private' do
    methods = described_class.methods(false)
    expect(methods.include?(:setprotoent)).to be(false)
    expect(methods.include?(:endprotoent)).to be(false)
  end
end
