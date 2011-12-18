require 'ffi'

# The Net module serves as a namespace only.
module Net
  # The Proto class serves as the base class for the various protocol methods.
  class Proto
    extend FFI::Library
    ffi_lib(FFI::Library::LIBC)

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

        psz = RUBY_PLATFORM == 'java' ? -1.size : self.class.size
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

    private_class_method :setprotoent
    private_class_method :endprotoent
    private_class_method :getprotobyname
    private_class_method :getprotobynumber
    private_class_method :getprotoent

    class << self
      alias getprotobyname_c getprotobyname
      alias getprotobynumber_c getprotobynumber
      alias getprotoent_c getprotoent
      remove_method :getprotobyname
      remove_method :getprotobynumber
      remove_method :getprotoent
    end

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
        setprotoent(0)
        ptr = getprotobyname_c(protocol)
        struct = ProtocolStruct.new(ptr) unless ptr.null?
      ensure
        endprotoent()
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
        setprotoent(0)
        ptr = getprotobynumber_c(protocol)
        struct = ProtocolStruct.new(ptr) unless ptr.null?
      ensure
        endprotoent()
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
        endprotoent()
      end

      structs
    end
  end
end
