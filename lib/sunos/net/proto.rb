require 'net/proto/common'

module Net
  class Proto
    ffi_lib 'socket'

    VERSION = '1.1.0'

    private_class_method :new

    attach_function :setprotoent, [:int], :void
    attach_function :endprotoent, [], :void
    attach_function :getprotobyname_r, [:string, :pointer, :pointer, :int], :pointer
    attach_function :getprotobynumber_r, [:int, :pointer, :pointer, :int], :pointer
    attach_function :getprotoent_r, [:pointer, :pointer, :int], :pointer

    private_class_method :setprotoent, :endprotoent, :getprotobyname_r
    private_class_method :getprotobynumber_r, :getprotoent_r

    public

    def self.get_protocol(argument)
      if argument.is_a?(String)
        getprotobyname(argument)
      else
        getprotobynumber(argument)
      end
    end

    def self.getprotobyname(protocol)
      raise TypeError unless protocol.is_a?(String)

      pptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      buff = FFI::MemoryPointer.new(:char, 1024)

      begin
        setprotoent(0)
        ptr = getprotobyname_r(protocol, pptr, buff, buff.size)
      ensure
        endprotoent()
      end

      ptr.null? ? nil : ProtocolStruct.new(pptr)[:p_proto]
    end

    def self.getprotobynumber(protocol)
      raise TypeError unless protocol.is_a?(Integer)

      pptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      buff = FFI::MemoryPointer.new(:char, 1024)

      begin
        setprotoent(0)
        ptr = getprotobynumber_r(protocol, pptr, buff, buff.size)
      ensure
        endprotoent()
      end

      ptr.null? ? nil : ProtocolStruct.new(pptr)[:p_name]
    end

    def self.getprotoent
      structs = block_given? ? nil : []

      pptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      buff = FFI::MemoryPointer.new(1024)

      begin
        setprotoent(0)

        while ptr = getprotoent_r(pptr, buff, buff.size)
          break if ptr.null?

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
