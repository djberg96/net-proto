require_relative '../../net/proto/common'

# The Net module serves as a namespace only.
module Net
  # The Proto class serves as the base class for the various protocol methods.
  class Proto
    extend FFI::Library

    ffi_lib FFI::Library::LIBC

    if File::ALT_SEPARATOR
      ffi_lib 'ws2_32'
      ffi_convention :stdcall
    end

    private

    # These should exist on every platform.
    attach_function :getprotobyname_c, :getprotobyname, [:string], :pointer
    attach_function :getprotobynumber_c, :getprotobynumber, [:int], :pointer

    private_class_method :getprotobyname_c
    private_class_method :getprotobynumber_c

    public

    # If given a protocol string, returns the corresponding number. If
    # given a protocol number, returns the corresponding string.
    #
    # Returns nil if not found in either case.
    #
    # Examples:
    #
    #   Net::Proto.get_protocol('tcp') # => 6
    #   Net::Proto.get_protocol(1)     # => 'icmp'
    #
    def self.get_protocol(arg)
      if arg.is_a?(String)
        getprotobyname(arg)
      else
        getprotobynumber(arg)
      end
    end

    # Given a protocol string, returns the corresponding number, or nil if
    # not found.
    #
    # Examples:
    #
    #    Net::Proto.getprotobyname('tcp')   # => 6
    #    Net::Proto.getprotobyname('bogus') # => nil
    #
    def self.getprotobyname(protocol)
      raise TypeError unless protocol.is_a?(String)

      begin
        ptr = getprotobyname_c(protocol)
        struct = ProtocolStruct.new(ptr) unless ptr.null?
      ensure
        endprotoent() if respond_to?(:endprotoent, true)
      end

      ptr.null? ? nil : struct[:p_proto]
    end

    # Given a protocol number, returns the corresponding string, or nil if
    # not found.
    #
    # Examples:
    #
    #   Net::Proto.getprotobynumber(6)   # => 'tcp'
    #   Net::Proto.getprotobynumber(999) # => nil
    #
    def self.getprotobynumber(protocol)
      raise TypeError unless protocol.is_a?(Integer)

      begin
        ptr = getprotobynumber_c(protocol)
        struct = ProtocolStruct.new(ptr) unless ptr.null?
      ensure
        endprotoent() if respond_to?(:endprotoent, true)
      end

      ptr.null? ? nil: struct[:p_name]
    end

    # In block form, yields each entry from /etc/protocols as a struct of type
    # Proto::ProtoStruct. In non-block form, returns an array of structs.
    #
    # The fields are 'name' (a string), 'aliases' (an array of strings,
    # though often only one element), and 'proto' (a number).
    #
    # Example:
    #
    #   Net::Proto.getprotoent.each{ |prot|
    #      p prot.name
    #      p prot.aliases
    #      p prot.proto
    #   }
    #
    def self.getprotoent
      structs = block_given? ? nil : []
      file = ENV['SystemRoot'] + '/system32/drivers/etc/protocol'

      IO.foreach(file) do |line|
        next if line.lstrip[0] == '#' # Skip comments
        next if line.lstrip.size == 0 # Skip blank lines
        line = line.split

        ruby_struct = ProtoStruct.new(line[0], line[2], line[1].to_i).freeze

        if block_given?
          yield ruby_struct
        else
          structs << ruby_struct
        end
      end

      structs
    end
  end
end

if $0 == __FILE__
  include Net
  Proto.getprotoent do |s|
    p s
  end
end