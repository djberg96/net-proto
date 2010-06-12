require 'ffi'

module Net
  class Proto
    extend FFI::Library

    unless RUBY_PLATFORM == 'java' && JRUBY_VERSION.to_f < 1.5
      ffi_lib(FFI::Library::LIBC)
    end

    # The version of the net-proto library
    VERSION = '1.1.0'

    private_class_method :new

    private

    class ProtocolStruct < FFI::Struct
      layout(
        :p_name,    :string,
        :p_aliases, :pointer,
        :p_proto,   :int
      ) 
    end

    class FFI::Pointer
      def read_array_of_string
        elements = []

        psz = RUBY_PLATFORM == 'java' ? 4 : self.class.size
        loc = self

        until ((element = loc.read_pointer).null?)
          elements << element.read_string
          loc += psz
        end

         elements
      end
    end

    ProtoStruct = Struct.new('ProtoStruct', :name, :aliases, :proto)

    attach_function 'setprotoent', [:int], :void
    attach_function 'endprotoent', [], :void
    attach_function 'getprotobyname_r', [:string, :pointer, :string, :long, :long], :int
    attach_function 'getprotobynumber_r', [:int, :pointer, :string, :long, :long], :int
    attach_function 'getprotoent_r', [:pointer, :string, :long, :pointer], :int

    public

    def self.getprotobyname(protocol)
      raise TypeError unless protocol.is_a?(String)

      ptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      buf = 1.chr * 8192

      begin
        setprotoent(0)
        int = getprotobyname_r(protocol, ptr, buf, buf.size, ptr.address)
      ensure
        endprotoent()
      end

      int > 0 ? nil : ProtocolStruct.new(ptr)[:p_proto]
    end

    # FIXME: Returns gibberish for some reason.
    def self.getprotobynumber(protocol)
      raise TypeError unless protocol.is_a?(Integer)

      ptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      buf = 1.chr * 8192

      begin
        setprotoent(0)
        int = getprotobynumber_r(protocol, ptr, buf, buf.size, ptr.address)
      ensure
        endprotoent()
      end

      int > 0 ? nil : ProtocolStruct.new(ptr)[:p_name]
    end

    def self.getprotoent
      structs = block_given? ? nil : []

      pptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      qptr = FFI::MemoryPointer.new(ProtocolStruct.size)
      buf  = 1.chr * 1024

      begin
        setprotoent(0)

        while int = getprotoent_r(pptr, buf, buf.size, qptr)
          break if int > 0 || qptr.null?
          buf = 1.chr * 1024

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
