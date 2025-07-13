# frozen_string_literal: true

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

    # Buffer size for protocol queries
    BUFFER_SIZE = 1024
    private_constant :BUFFER_SIZE

    # Allocates memory pointers needed for protocol queries
    #
    # @return [Array<FFI::MemoryPointer>] Array containing [pptr, qptr, buf]
    def self.allocate_protocol_pointers
      pptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      qptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      buf  = FFI::MemoryPointer.new(:char, BUFFER_SIZE)
      [pptr, qptr, buf]
    end

    # Safely executes a protocol query with proper resource cleanup
    #
    # @yield Block to execute between setprotoent and endprotoent calls
    # @return [Object] Result of the yielded block
    def self.with_protocol_context
      setprotoent(0)
      yield
    ensure
      endprotoent
    end

    # Checks if the protocol query was successful
    #
    # @param int [Integer] Return value from protocol function
    # @param qptr [FFI::MemoryPointer] Pointer to result pointer
    # @return [Boolean] true if query failed, false if successful
    def self.protocol_query_failed?(int, qptr)
      int > 0 || qptr.get_pointer(0).null?
    end

    private_class_method :allocate_protocol_pointers, :with_protocol_context, :protocol_query_failed?

    # If given a protocol string, returns the corresponding number. If
    # given a protocol number, returns the corresponding string.
    #
    # Returns nil if not found in either case.
    #
    # @param argument [String, Integer] The protocol name or number to look up
    # @return [Integer, String, nil] The corresponding protocol number/name, or nil if not found
    # @raise [TypeError] if argument is not a String or Integer
    #
    # Examples:
    #
    #   Net::Proto.get_protocol('tcp') # => 6
    #   Net::Proto.get_protocol(1)     # => 'icmp'
    #
    def self.get_protocol(argument)
      if argument.is_a?(String)
        getprotobyname(argument)
      elsif argument.is_a?(Integer)
        getprotobynumber(argument)
      else
        raise TypeError, 'Argument must be a String or Integer'
      end
    end

    # Given a protocol string, returns the corresponding number, or nil if
    # not found.
    #
    # @param protocol [String] The protocol name to look up
    # @return [Integer, nil] The protocol number, or nil if not found
    # @raise [TypeError] if protocol is not a String
    #
    # Examples:
    #
    #    Net::Proto.getprotobyname('tcp')   # => 6
    #    Net::Proto.getprotobyname('bogus') # => nil
    #    Net::Proto.getprotobyname('')      # => nil
    #
    def self.getprotobyname(protocol)
      raise TypeError, 'Protocol must be a String' unless protocol.is_a?(String)

      # Return nil for empty or whitespace-only strings
      return nil if protocol.strip.empty?

      pptr, qptr, buf = allocate_protocol_pointers

      with_protocol_context do
        int = getprotobyname_r(protocol, pptr, buf, buf.size, qptr)
        protocol_query_failed?(int, qptr) ? nil : ProtocolStruct.new(pptr)[:p_proto]
      end
    end

    # Given a protocol number, returns the corresponding string, or nil if
    # not found.
    #
    # @param protocol [Integer] The protocol number to look up
    # @return [String, nil] The protocol name, or nil if not found
    # @raise [TypeError] if protocol is not an Integer
    #
    # Examples:
    #
    #   Net::Proto.getprotobynumber(6)   # => 'tcp'
    #   Net::Proto.getprotobynumber(999) # => nil
    #   Net::Proto.getprotobynumber(-1)  # => nil
    #
    def self.getprotobynumber(protocol)
      raise TypeError, 'Protocol must be an Integer' unless protocol.is_a?(Integer)

      # Return nil for negative numbers (invalid protocol numbers)
      return nil if protocol < 0

      pptr, qptr, buf = allocate_protocol_pointers

      with_protocol_context do
        int = getprotobynumber_r(protocol, pptr, buf, buf.size, qptr)
        protocol_query_failed?(int, qptr) ? nil : ProtocolStruct.new(pptr)[:p_name]
      end
    end

    # In block form, yields each entry from /etc/protocols as a struct of type
    # Proto::ProtoStruct. In non-block form, returns an array of structs.
    #
    # The fields are 'name' (a string), 'aliases' (an array of strings,
    # though often only one element), and 'proto' (a number).
    #
    # @yield [ProtoStruct] Each protocol entry if a block is given
    # @return [Array<ProtoStruct>, nil] Array of protocol structs if no block given,
    #   nil if block given
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
      buf  = FFI::MemoryPointer.new(BUFFER_SIZE)

      with_protocol_context do
        loop do
          int = getprotoent_r(pptr, buf, buf.size, qptr)
          break if int > 0 || qptr.null?

          # Reallocate buffer if needed
          buf = FFI::MemoryPointer.new(BUFFER_SIZE)

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
      end

      structs
    end
  end
end
