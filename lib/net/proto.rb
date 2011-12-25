require 'ffi'

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

        loc = self

        until ((element = loc.read_pointer).null?)
          elements << element.read_string
          loc += FFI::Type::POINTER.size
        end

        elements
      end
    end

    ProtoStruct = Struct.new('ProtoStruct', :name, :aliases, :proto)

    # These should exist on every platform.
    attach_function 'getprotobyname', [:string], :pointer
    attach_function 'getprotobynumber', [:int], :pointer

    # These are defined on most platforms, but not all.
    begin
      attach_function 'setprotoent', [:int], :void
      attach_function 'endprotoent', [], :void
      attach_function 'getprotoent', [], :pointer
    rescue FFI::NotFoundError
      # Ignore, not supported. Probably Windows.
    else
      private_class_method :setprotoent
      private_class_method :endprotoent
      private_class_method :getprotoent
    end

    private_class_method :getprotobyname
    private_class_method :getprotobynumber

    # We use these as our own method names in the public API, so we need
    # to create aliases for them, then remove the original method name.
    # Later, we'll use the aliases internally.
    #
    class << self
      alias getprotobyname_c getprotobyname
      alias getprotobynumber_c getprotobynumber
      remove_method :getprotobyname
      remove_method :getprotobynumber
    end

    if respond_to?(:getprotoent, true)
      class << self
        alias getprotoent_c getprotoent
        remove_method :getprotoent
      end
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
        setprotoent(0) if respond_to?(:setprotoent, true)
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
        setprotoent(0) if respond_to?(:setprotoent, true)
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
      raise NoMethodError unless respond_to?(:getprotoent, true)

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
