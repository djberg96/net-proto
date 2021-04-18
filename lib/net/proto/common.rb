# frozen_string_literal: true

require 'ffi'

module Net
  class Proto
    extend FFI::Library

    # The version of the net-proto library
    VERSION = '1.4.2'.freeze

    private_class_method :new

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
  end
end
