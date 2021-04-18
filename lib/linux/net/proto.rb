require 'net/proto/common'

# The Net module serves as a namespace only.
module Net

  # The Proto class serves as the base class for the various protocol methods.
  class Proto
    ffi_lib FFI::Library::LIBC

    attach_function :setprotoent, [:int], :void
    attach_function :endprotoent, [], :void
    attach_function :getprotobyname_r, %i[string pointer pointer long pointer], :int
    attach_function :getprotobynumber_r, %i[int pointer pointer long pointer], :int
    attach_function :getprotoent_r, %i[pointer pointer long pointer], :int

    private_class_method :setprotoent, :endprotoent, :getprotobyname_r
    private_class_method :getprotobynumber_r, :getprotoent_r

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
    def self.get_protocol(argument)
      if argument.is_a?(String)
        getprotobyname(argument)
      else
        getprotobynumber(argument)
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

      pptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      qptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      buf  = FFI::MemoryPointer.new(:char, 1024)

      begin
        setprotoent(0)
        int = getprotobyname_r(protocol, pptr, buf, buf.size, qptr)
      ensure
        endprotoent()
      end

      int > 0 || qptr.get_pointer(0).null? ? nil : ProtocolStruct.new(pptr)[:p_proto]
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

      pptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      qptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      buf  = FFI::MemoryPointer.new(:char, 1024)

      begin
        setprotoent(0)
        int = getprotobynumber_r(protocol, pptr, buf, buf.size, qptr)
      ensure
        endprotoent()
      end

      int > 0 || qptr.get_pointer(0).null? ? nil : ProtocolStruct.new(pptr)[:p_name]
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

      pptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      qptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      buf  = FFI::MemoryPointer.new(1024)

      begin
        setprotoent(0)

        while int = getprotoent_r(pptr, buf, buf.size, qptr)
          break if int > 0 || qptr.null?
          buf = FFI::MemoryPointer.new(1024)

          ffi_struct = ProtocolStruct.new(pptr)

          ruby_struct = ProtoStruct.new(
            ffi_struct[:p_name],
            ffi_struct[:p_aliases].read_array_of_string,
            ffi_struct[:p_proto]
          ).freeze

          if block_given?
            yield ruby_struct
          else
            structs << ruby_struct
          end
        end
      ensure
        endprotoent
      end

      structs
    end
  end
end
