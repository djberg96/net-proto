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
    attach_function 'getprotobyname', [:string], :pointer
    attach_function 'getprotobynumber', [:int], :pointer
    attach_function 'getprotoent', [], :pointer

    class << self
      alias getprotobyname_c getprotobyname
      alias getprotobynumber_c getprotobynumber
      alias getprotoent_c getprotoent
    end

    public

    def self.getprotobyname(protocol)
      raise TypeError unless protocol.is_a?(String)

      begin
        setprotoent(0)
        ptr = getprotobyname_c(protocol) 
        struct = ProtocolStruct.new(ptr) unless ptr.null?
      ensure
        endprotoent()
      end

      ptr.null? ? nil : struct[:p_proto]
    end

    def self.getprotobynumber(protocol)
      raise TypeError unless protocol.is_a?(Integer)

      begin
        setprotoent(0)
        ptr = getprotobynumber_c(protocol)
        struct = ProtocolStruct.new(ptr) unless ptr.null?
      ensure
        endprotoent()
      end

      ptr.null? ? nil: struct[:p_name]
    end

    def self.getprotoent
      structs = block_given? ? nil : []

      begin
        setprotoent(0)
        until (ptr = getprotoent_c()).null?
          ffi_struct  = ProtocolStruct.new(ptr)

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
