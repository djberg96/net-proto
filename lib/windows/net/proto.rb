require 'net/proto/common'

# The Net module serves as a namespace only.
module Net
  # The Proto class serves as the base class for the various protocol methods.
  class Proto
    extend FFI::Library

    ffi_lib FFI::Library::LIBC
    ffi_lib 'ws2_32'
    ffi_convention :stdcall

    private

    # These should exist on every platform.
    attach_function :getprotobyname_c, :getprotobyname, [:string], :pointer
    attach_function :getprotobynumber_c, :getprotobynumber, [:int], :pointer
    attach_function :WSAAsyncGetProtoByName, [:uintptr_t, :uint, :string, :pointer, :pointer], :uintptr_t
    attach_function :WSAAsyncGetProtoByNumber, [:uintptr_t, :uint, :int, :pointer, :pointer], :uintptr_t
    attach_function :WSAGetLastError, [], :int

    private_class_method :getprotobyname_c
    private_class_method :getprotobynumber_c
    private_class_method :WSAAsyncGetProtoByName
    private_class_method :WSAAsyncGetProtoByNumber
    private_class_method :WSAGetLastError

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
    # On MS Windows, you may also pass a window handle and a message (int)
    # that window will receive. If present, this method becomes asynchronous
    # and yields a block instead, with the protocol and handle.
    #
    # Example:
    #
    #   Net::Proto.getprotobyname('tcp', SOME_WINDOW, SOME_MSG){ |num, handle| ... }
    #
    def self.getprotobyname(protocol, hwnd = 0, msg = 0)
      raise TypeError unless protocol.is_a?(String)

      if hwnd && hwnd > 0
        struct = ProtocolStruct.new
        size_ptr = FFI::MemoryPointer.new(:int)
        size_ptr.write_int(struct.size)

        handle = WSAAsyncGetProtoByName(hwnd, msg, protocol, struct, size_ptr)

        if handle == 0
          raise SystemCallError.new('WSAAsyncGetProtoByName', WSAGetLastError())
        end

        yield struct[:p_proto], handle
      else
        begin
          ptr = getprotobyname_c(protocol)
          struct = ProtocolStruct.new(ptr) unless ptr.null?
        ensure
          endprotoent() if respond_to?(:endprotoent, true)
        end
        ptr.null? ? nil : struct[:p_proto]
      end
    end

    # Given a protocol number, returns the corresponding string, or nil if
    # not found.
    #
    # Examples:
    #
    #   Net::Proto.getprotobynumber(6)   # => 'tcp'
    #   Net::Proto.getprotobynumber(999) # => nil
    #
    # On MS Windows, you may also pass a window handle and a message (int)
    # that window will receive. If present, this method becomes asynchronous
    # and yields a block instead, with the protocol and handle.
    #
    # Example:
    #
    #   Net::Proto.getprotobynumber(6, SOME_WINDOW, SOME_MSG){ |name, handle| ... }
    #
    def self.getprotobynumber(protocol, hwnd = 0, msg = 0)
      raise TypeError unless protocol.is_a?(Integer)

      if hwnd && hwnd > 0
        struct = ProtocolStruct.new
        size_ptr = FFI::MemoryPointer.new(:int)
        size_ptr.write_int(struct.size)

        handle = WSAAsyncGetProtoByNumber(hwnd, msg, protocol, struct, size_ptr)

        if handle == 0
          raise SystemCallError.new('WSAAsyncGetProtoByNumber', WSAGetLastError())
        end

        yield struct[:p_name], handle
      else
        begin
          ptr = getprotobynumber_c(protocol)
          struct = ProtocolStruct.new(ptr) unless ptr.null?
        ensure
          endprotoent() if respond_to?(:endprotoent, true)
        end

        ptr.null? ? nil : struct[:p_name]
      end
    end

    # In block form, yields each entry from /etc/protocol as a struct of type
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
    # Note that on Windows this code reads directly out of a %SystemRoot%
    # subfolder using pure Ruby, so you will need read access or this method
    # will fail.
    #
    def self.getprotoent
      structs = block_given? ? nil : []
      file = ENV['SystemRoot'] + '/system32/drivers/etc/protocol'

      IO.foreach(file) do |line|
        next if line.lstrip[0] == '#' # Skip comments
        next if line.lstrip.size == 0 # Skip blank lines
        line = line.split

        ruby_struct = ProtoStruct.new(line[0], line[2].split(','), line[1].to_i).freeze

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
