# frozen_string_literal: true

require 'ffi'

# The Net module serves as a namespace only.
module Net
  # The Proto class serves as the base class for the various protocol methods.
  class Proto
    extend FFI::Library

    # The version of the net-proto library
    VERSION = '1.4.2'

    private_class_method :new

    # Struct used internally by C functions
    class ProtocolStruct < FFI::Struct
      if File::ALT_SEPARATOR
        layout(
          :p_name,    :string,
          :p_aliases, :pointer,
          :p_proto,   :short
        )
      else
        layout(
          :p_name,    :string,
          :p_aliases, :pointer,
          :p_proto,   :int
        )
      end
    end

    private_constant :ProtocolStruct

    # Reopen the FFI::Pointer class and add our own method.
    class FFI::Pointer
      def read_array_of_string
        elements = []

        loc = self

        until (element = loc.read_pointer).null?
          elements << element.read_string
          loc += FFI::Type::POINTER.size
        end

        elements
      end
    end

    ProtoStruct = Struct.new('ProtoStruct', :name, :aliases, :proto)
  end
end
